#!/usr/bin/perl -w

###  makes a mapset from pixel file for a single conversion factor.

## cat <pixel mapset> | makeMapsetFromPixel.1.pl -factor 194 -runID 880 > run880.cool.maps


use strict;
use Carp;
use English;
use Getopt::Long;

my $factor;
my $minSize = 100; ## kb
my $minFrags = 10;
my $runID = 734;

GetOptions (
	    'factor=s'     => \$factor,
	    'minSize=i'    => \$minSize,
	    'minFrags=i'   => \$minFrags,
	    'runID=i'      => \$runID,
	    );



$factor = 200 unless ($factor);

my @pixelMaps;
{
  local $RS = "\n\n";
  @pixelMaps = <>;
}

foreach my $map (@pixelMaps) {
  my @f = split (" ",$map);

  my $mapName = $f[0];
  my ($grp,$run,$mol) = $mapName =~/^(\d+)_(\d+)_(\d+)/;
  $mol += $factor*10000;
  $mapName = join ("_",$grp,$runID, $mol);
  #print join "\t", $f[0],$mapName,"\n";
  
  my @frags = @f[3..$#f];
  next unless (@frags >= $minFrags);
  my $length;
  map{$_ *= $factor/1000; $length += $_} @frags;
  next unless ($length >= $minSize);
  @frags = map{ sprintf "%.3f", $_} @frags;
  print "$mapName\n\t$f[1]\t$f[2]\t", join("\t",@frags),"\n\n";
}




__END__

cd ..
jabba$ for f in mesoplasmINCA_OCT23_wiggletight/group1-2064*disttight.maps; do cat $f |perl -nle 'BEGIN{$f=shift; $f=~s%.*/%%; $f=~s/tight//;  open M,">pixel/$f"} s/\cM//g; s/NtBspQ1/NtBspQI/; print M' $f; done

for dir in factor_0.*; do for f in pixel/group1-2064*; do grp=${f/pixel\//}; cat $f |perl -nale 'BEGIN{$factor=shift; $factor=~s/factor_//; }  if (/Nt/) {map{$_*=$factor} @F[2..$#F]; print join "\t","",@F;} else {print};' $dir >  $dir/$grp;  done; done 

