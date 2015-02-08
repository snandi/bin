#!/usr/bin/perl -w

### Print table with pixel intensities for each aligned nMap fragment at the specified location.

###  ./intensityForAlignedFrags.pl -chrom <CHR> -fragIndex <N> | -bpLoc <bp> | -kbLoc <kb>
###     -alignmentChunks <file>   -nMapFluor <file>  -goldFragmentsOnly

use strict;
use Carp;
use English;
use Getopt::Long;

my $goldFragmentsOnly = 1;
my $alignmentChunks  = "/aspen/steveg/human_nMaps/GC_content/subdivideFragments/alignments/merged.alignmentLocations";

my $nMapFluor = "/aspen/steveg/human_nMaps/GC_content/subdivideFragments/pixelIntensities.eachFragment.all7134Groups";

#my $conversionFactor = 206;
my $chromosome;
my $fragIndex;
my $bpCoord;
my $kbCoord;

GetOptions (
	    'goldFragmentsOnly!'  => \$goldFragmentsOnly,
	    'alignmentChunks=s'   => \$alignmentChunks,
	    'nMapFluor=s'         => \$nMapFluor,
	    'chromosome=s'        => \$chromosome, # Changed chromosome=i to chromosome=s, to accommodate X & Y
	    'fragIndex=i'         => \$fragIndex,
	    'bpCoord=i'           => \$bpCoord,
	    'kbCoord=i'           => \$kbCoord,
	    );

if (defined $bpCoord or defined $kbCoord) {

  carp "using coordinate not fragment index" 
    if (defined $fragIndex);

  if (defined $kbCoord) {
    carp "using bp coordinate not kb coordinate"
      if (defined $bpCoord);
    $bpCoord = $kbCoord * 1000;
  }
  croak "Usage   intensityForAlignedFrags.pl -chr <chr> -bpCoord <N>|-kbCoord <N>"
    unless (defined $chromosome);
}

else {

  croak "Usage   intensityForAlignedFrags.pl -chr <chr> -fragIndex <N>"
    unless (defined $chromosome and defined $fragIndex);
}



my %fragsToReport;
my @refData;
## Stream through the alignment chunks and save the ones specified on the command line.
open CHUNKS, $alignmentChunks or croak "Can't read alignment file $alignmentChunks";

while (<CHUNKS>) {
  chomp;
  my (
      $chr,$start1,$end1,
      $nMapID,$start2,$end2,
      $rCoord1,$rCoord2,
      $nCoord1,$nCoord2,
      $orient,$lengthRatio,
     ) = split;
  $chr=~s/^chr//;
  next unless ($chr eq $chromosome);
  if ($goldFragmentsOnly) {
    next unless ($end1 - $start1 == 1 and abs($end2-$start2) == 1);
  }

  if (not defined $fragIndex) {
    next unless ($bpCoord >= $rCoord1 and $bpCoord <= $rCoord2);
    $fragIndex = $start1;
  }
  else {
    next unless ($start1 == $fragIndex);
  }


  if (not @refData) {
    ## the first time through, save the reference coordinates;
    @refData = ($chr,$start1,$rCoord1,$rCoord2);
  }

  $nMapID =~ s/^omdb:\d+://;

  if ($orient == -1) {
    my @s = ($end2,$start2);
    $start2=$s[0];
    $end2 = $s[1];
    my @n = ($nCoord2,$nCoord1);
    $nCoord1 = $n[0];
    $nCoord2 = $n[1];
  }

  $fragsToReport{$nMapID}->{$start2} =
    [
     $nCoord1,$nCoord2,
     $orient,
    ];
} ##while CHUNKS
close CHUNKS;


##############
my @header = qw(
		 moleculeID
		 fragmentIndex
		 fragmentLength
		 nMapCoordStart
		 nMapCoordEnd
		 orientation

		 alignedChr
		 alignedFragIndex
		 refMapCoordStart
		 refMapCoordEnd

		 pixelIntensity
	      );
############## print header at the end;

open FLUOR, $nMapFluor or croak "Can't read fluor intensities $nMapFluor"; 

my $maxArrayLength = 0;
my @outputBuffer;

while(<FLUOR>) { 
  chomp; 
  my ($nMapID,$fragmentIndex,$fragmentLength,@pixelIntensity)  = split;

  next unless (exists $fragsToReport{$nMapID}->{$fragmentIndex});
  my $dat = $fragsToReport{$nMapID}->{$fragmentIndex};
  if ($dat->[2] == -1) {  ## dat->[2] is orientation of alignment
    @pixelIntensity = reverse( @pixelIntensity);
  }

  $maxArrayLength = scalar @pixelIntensity   
    if (scalar @pixelIntensity > $maxArrayLength);

  push @outputBuffer ,[
		       $nMapID,$fragmentIndex,$fragmentLength,
		       @$dat,    ### nMap coordinates and orientation
		       @refData, ##  ref Map coordinates
		       @pixelIntensity,
		      ];
}

### pad with NAs and adjust header to make the R code easier.

my @adjustedHeader = @header[0..$#header-1];

map{push @adjustedHeader, $header[-1] . $_} (1..$maxArrayLength);
print join("\t",@adjustedHeader), "\n";


foreach my $outputLine (@outputBuffer) {
  my $NAsNeeded = scalar @adjustedHeader - scalar @$outputLine;
  @$outputLine = (@$outputLine, ("NA") x $NAsNeeded);
}

map{print join("\t", @$_), "\n"} @outputBuffer;


__END__
