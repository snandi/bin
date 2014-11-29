#!/usr/bin/perl

### Front end to SomaAlignmentLocations:
##   additional features:  can take a list of xml files as input.
##                         can create a seqloc file on the fly.

## usage : xml2loc.pl <xmlFile| -filelist xmlfilelist >
##   options:  -seqloc <seqloc file> or -chromosome to create it on the fly.
##             -minscore <score>  -mincount<count>
##             -outdir <dir>
##             -stdout -write output to STDOUT.
##             -extended

use strict;
use Carp;
use English;
use warnings;
use Getopt::Long;
use File::Basename;
use IO::File;

my $minScore;
my $minCount;
my $seqloc;
my $extended = 1;
my $refedge = 0;
my $outdir;
my $filelist;
my $stdout = 0;
my $allowDuplicateMaps = 0;

GetOptions (
	    'minScore=f'  => \$minScore,
	    'minCount=i'  =>  \$minCount,
	    'seqloc=s'    =>  \$seqloc,
	    'extended!'   =>  \$extended,
	    'refedge!'    =>  \$refedge,
	    'outdir=s'    =>  \$outdir,
	    'filelist=s'  =>  \$filelist,
	    'stdout!'     =>  \$stdout,
	    'allowDuplicateMaps!' => \$allowDuplicateMaps,
	    );

if (defined $filelist) {
  open F, $filelist
    or croak "Can't open $filelist";
  while(<F>) {
    chomp;
    next if /^\s*$/;
    next if /^\s*\#/;
    my @F = split;
    push @ARGV, $F[0];
  }
  close F;
}

my $SomaLocCmd;
if (not $allowDuplicateMaps) {
  $SomaLocCmd =
    '/omm/bin/javarun.sh edu.wisc.lmcg.programs.SomaAlignmentLocations';
}
else {
  ## This is a hacked version with the duplicate maps error turned off.
  ##  It's a hack because if the reference (or aligned) mapset has duplicates,
  ##   the error is ignored;
  ##  The intent is to allow parsing of an alignment of a mapset
  ##           against itself.
  $SomaLocCmd =
    '/home/hdlu/bin//javarun.sh edu.wisc.lmcg.programs.SomaAlignmentLocations';
  $SomaLocCmd .= ' -duplcmap';
}
## bug in soma loc says minchunks instead of mincount.
$SomaLocCmd .= " -minchunks $minCount" if (defined $minCount);
$SomaLocCmd .= " -minscore $minScore" if (defined $minScore);
$SomaLocCmd .= " -extended" if ($extended);
$SomaLocCmd .= " -refedge" if ($refedge);
$SomaLocCmd .= " -seqloc $seqloc" if (defined $seqloc);

foreach my $xmlFile (@ARGV) {
  my $outFile = basename($xmlFile, '.xml', '.xml.gz');
  my $dirname = dirname($xmlFile);
  $dirname = $outdir if (defined $outdir);
  $outFile = "$dirname/$outFile.loc"; 
  my $fh;
  if ($stdout) {
    $fh = *STDOUT;
  }
  elsif (not ($fh = new IO::File(">$outFile"))) {
    carp "Can't write to $outFile.\n\t$xmlFile skipped.";
    next;
  }
  my $tmpErr="/tmp/xml2loc.$PID.err";
  print $fh `$SomaLocCmd -f $xmlFile 2> $tmpErr`;
  carp "Error parsing $xmlFile:\n", `cat $tmpErr`
    if (-s $tmpErr);
  unlink $tmpErr;
}



__END__

new=${1/xml/loc}


/omm/bin/javarun.sh edu.wisc.lmcg.programs.SomaAlignmentLocations -f $1 -seqlo


   /omm/bin/javarun.sh edu.wisc.lmcg.programs.SomaAlignmentLocations   \
   -f $f                                                               \
   -seqloc /omm/etc/humandb/human_b35_locs                             \
   -minscore 4.5                                                       \
   -minchunks 10  >> human.noisysqrt.locs; done

