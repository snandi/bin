#!/usr/bin/perl -w 


use strict;
use Carp;
use English;
use Getopt::Long;

my $printLen = 0;
my $chopEnds = 0;

GetOptions (
	    'printLen!'  => \$printLen,
	    'chopEnds!'  => \$chopEnds,
	    );

## Perl Cookbook reciped 16.6
@ARGV = map {/\.gz$/ ? "gzip -dc $_ |" :$_} @ARGV;

my $inAlignment = 0;
my ($refName, $opName, $score, $pval, $count);
my $orientation = 'N';
my @alignmentCoordinates;
my @lastCoordinates;
my %mapSizes;
my $mapName;


while (<>) {
    
  #### take care of the map size
  if (/<map_block>(.*)<\/map_block>/) {
    my @array = split / /, $1;
    $mapSizes{$mapName}->{numFrags} = scalar @array;
    my $length;
    map {$length += $_} @array;
    $length -= $array[0]+$array[$#array] if ($chopEnds);
    $mapSizes{$mapName}->{length} = $length;
    next;
  }
  if (not $inAlignment and /<name>(.*)<\/name>/) {
    $mapName = $1;
    $mapName =~ s/^.*Hs/Hs/ unless (/noisy/); 
    ### For human in silico, truncate the name
    $mapName =~ s/^omdb:-1:(noisy:\d+:\d+:\d+).*Hs/$1Hs/; #For simulated data
    next;
  }
	

  if (/<map_alignment>/ ) {
    $inAlignment =1 ;
    $pval= '';
    next;
  }
  next unless ($inAlignment);

  if (/<\/map_alignment>/) {
    $inAlignment = 0;
    my $refLen='';
    my $opLen='';
    if ($printLen) {
      $refLen = "$mapSizes{$refName}->{length}:"; 
      $opLen = "$mapSizes{$opName}->{length}:"; 
    }
    print "$refName($refLen$mapSizes{$refName}->{numFrags}:",
      "$alignmentCoordinates[1]-$lastCoordinates[1]) ",
	"$opName($opLen$mapSizes{$opName}->{numFrags}:",
	  "$alignmentCoordinates[0]-$lastCoordinates[0])$orientation ";
    print "$score $pval $count\n";
    #print "($alignmentCoordinates[0],$alignmentCoordinates[1])-",
    #"($lastCoordinates[0],$lastCoordinates[1])$orientation\n";
    @alignmentCoordinates = ();
    $refName = '';
    next;
  }
  
  if (/<name>(.*)<\/name>/) {
    my $name = $1;
    $name =~ s/^.*Hs/Hs/ unless (/noisy/); 
    ### For human in silico, truncate the name
    $name =~ s/^omdb:-1:(noisy:\d+:\d+:\d+).*Hs/$1Hs/; #For simulated data
    if ($refName) {
      $opName = $name;
    } else {
      $refName = $name;
    }
    next;
  }
  if (/<orientation>([NR])</) {
    if ($1 eq 'R') {
      $orientation = $1;
    } else {
      ### Don't need to print forward orientation
      $orientation = '';
    }
    next;
  }

  if (/<[^>]*_score>(.*)</) {
    $score = $1;
    next;
  }
  if (/<soma_pvalue>(.*)</) {
    $pval = $1;
    #print "$1 ";
    next
  } 

  if (/<count>(.*)</) {
    $count = $1;
    #print "$1 ";
    next;
  }

  if (m{<f><i>(\d+)</i><l>(\d+)</l><r>(\d+)</r></f>}) {
    if (@alignmentCoordinates) {
      @lastCoordinates = ($1,$3);
    } else {
      @alignmentCoordinates = ($1,$2);
      @lastCoordinates = ($1,$3); ### in case there is only one frag in 
      ##  the alignment  
    }
  }
  

}				#while

