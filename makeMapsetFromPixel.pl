#!/usr/bin/perl -w

### cat <pixel maps> | makeMapsetFromPixel.pl 
### makes a dir for each factor and writes mapset in it.
### Changed by Mike Place (5/10/2013):
### to create a single mapset at 1 factor and accept input file name
### and write the output file to the current dir


use strict;
use Carp;
use English;
use Getopt::Long;

my @factor;
#my $minSize = 100; ## kb for human
my $minSize = 0;
#my $minFrags = 10;  ## for human
my $minFrags = 3; 
my $file = $ARGV[0];
my $cfac;


GetOptions (
	    'factor=s'     => \@factor,
	    'minSize=i'    => \$minSize,
	    'minFrags=i'   => \$minFrags,
	    );

@factor = split ",",join(",",@factor);
@factor = qw(0.209)                     # change conversion factor here

## ADD LIST OF CONVERSION FACTORS:
#@factor = qw(0.189 0.198 0.217 0.228 0.240)  ## quote to preserve trailing 0
  ## corresponds to nominal stretch (115%,110%,100%,95%)
  unless (@factor);

#$cfac = $factor[0];          # factor name use to write output file
#$cfac =~ s/0\.//;
  

my @pixelMaps;
{
  local $RS = "\n\n";
  @pixelMaps = <>;
}

foreach my $factor (@factor) {
  #my $outdir = "./factor_$factor";
  $cfac = $factor;          # factor name use to write output file
  $cfac =~ s/0\.//;

  my $outdir = ".";  # write to current dir
  if (not -d $outdir) {
    mkdir $outdir
      or croak "Can't make dir $outdir";
  }
  my $outfile = "$file.$cfac.maps";
  open OUT, ">$outfile"
    or croak "Can't write to $outfile";
  foreach my $map (@pixelMaps) {
    my @f = split (" ",$map);
    my @frags = @f[3..$#f];
    next unless (@frags >= $minFrags);
    my $length;
    map{$_ *= $factor; $length += $_} @frags;
    next unless ($length >= $minSize);
    print OUT "$f[0]\n\t$f[1]\t$f[2]\t", join("\t",@frags),"\n\n";
  }
  close OUT;
}



__END__

cd ..
jabba$ for f in mesoplasmINCA_OCT23_wiggletight/group1-2064*disttight.maps; do cat $f |perl -nle 'BEGIN{$f=shift; $f=~s%.*/%%; $f=~s/tight//;  open M,">pixel/$f"} s/\cM//g; s/NtBspQ1/NtBspQI/; print M' $f; done

for dir in factor_0.*; do for f in pixel/group1-2064*; do grp=${f/pixel\//}; cat $f |perl -nale 'BEGIN{$factor=shift; $factor=~s/factor_//; }  if (/Nt/) {map{$_*=$factor} @F[2..$#F]; print join "\t","",@F;} else {print};' $dir >  $dir/$grp;  done; done 

