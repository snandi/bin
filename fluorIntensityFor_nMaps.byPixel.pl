#!/usr/bin/perl -w

####  for each fragment (interval) list the intensities at each pixel.
##  

use strict;
use Carp;
use English;
use Getopt::Long;
use English;

my $test =0;
GetOptions (
	    'test!'      => \$test,
	    );


my $runID = 734;
#my $conversionFactor = 203;
my $conversionFactor = 206;

### Get all the groups;

my $testDir =
  '/aspen/steveg/human_nMaps/GC_content/subdivideFragments/testDir/maps-inca34';

my @dirs = map{"/aspen/prabu/mm52-$_/maps-inca34/"}("all7341");
if ($test) {
  @dirs = ($testDir);
}

my @grpDirs;
foreach my $incaDir (@dirs) {
  opendir D, $incaDir or croak "Can't read INCA dir $incaDir";
  my @theseGrpDirs = grep {/group1-\d+-/} readdir D;
  @theseGrpDirs = map{"$incaDir/$_"} @theseGrpDirs;
  push @grpDirs,@theseGrpDirs;
  closedir D;
}

## Get all the molecule<>.txt files
my @moleculeTxtFiles;

#foreach my $dir (@grpDirs) {
foreach my $dir (@grpDirs) {
  opendir D, $dir or croak "Can't open group dir $dir";
  my @molFile = grep {/^molecule\d+.txt$/} readdir D;
  @molFile = map{"$dir/$_"} @molFile;
  push @moleculeTxtFiles, @molFile;
  closedir D;
}

my @header = qw(moleculeID fragmentIndex fragmentLength pixelIntensities);
print join("\t",@header), "\n";

foreach my $moleculeTxtFile (sort @moleculeTxtFiles) {
  my ($grp,$mol) = $moleculeTxtFile=~m%group1-(\d+)-.*/molecule(\d+)\.txt$%;
  open MOLTXT, $moleculeTxtFile
    or croak "Can't read molecule txt file: $moleculeTxtFile";
  my $molID = $conversionFactor*10000 + $mol;
  $molID = join("_",$grp,$runID, $molID);

  my $line = <MOLTXT>;
  chomp $line;
  my ($numPix, $numPunctates, $numFrags) = split (/ /, $line);

  my @intensity;
  my @punctateIndex;
  my @pixelLengths;

  while(<MOLTXT>) {
    chomp;
    my @F = split;
    if ($#F == 3) {
      push @intensity, $F[2];
    }
    elsif ($#F==1) {
      push @punctateIndex, $F[0];
    }
    elsif ($#F == 2) {
      push @pixelLengths, $F[0];
    }
    else {
      croak "Wrong number of fields: $_";
    }
  }

  croak "Wrong number of pixels"
    unless (@intensity == $numPix);

  croak "Wrong number of fragments"
    unless (@pixelLengths == $numFrags);


  my @intensitySum;
  foreach my $frag (0..$numFrags-1) {
    my $start = $punctateIndex[$frag];
    my $end   = $punctateIndex[$frag+1];

    my $approx3Length = $pixelLengths[$frag];
    my $kbLength = sprintf("%.3f",$approx3Length * $conversionFactor/1000);

    print join("\t",$molID,$frag,$kbLength,@intensity[$start..$end]),
      "\n";
  } ## foreach frag
} ## foreach molecule


__END__


Add length of the nMap (or approx3 nPixels in fluor intensity) and num frags to table   because the stretch may depend on length.

Change alignment to delete molecules with multiple alignments --- multiple alignments may be errors.


sliding windows for pixels;

/aspen/prabu/mm52-quick50/maps-inca34/group1-2334067-inca34-outputs/molecule1.txt


