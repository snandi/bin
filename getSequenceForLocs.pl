#!/usr/bin/perl

## Usage: 

use strict;
use warnings;
use English;
use Carp;

use Getopt::Long;
my $locFile;
my $match = '^chr(.*)$';  ## mapping fasta seq name to loc file chr;

GetOptions (
	    'locFile=s'  => \$locFile,
	    'match=s'   => \$match,
	   );

open LOC, $locFile
  or croak "Can't open $locFile";
my %locs;
while(<LOC>) {
  chomp;
  s/\#.*$//;
  next if (/^\s*$/);
  my @F = split /,/;
  push @{$locs{$F[1]}}, [@F[0,2,3]];
}
close LOC;

my @seqNamesInOrder;
my $seqName;
my $sequence;
while (<>) {
  chomp;
  if (s/^>//) {
    if (defined $seqName and exists $locs{$seqName}) {
      my $subSeqs = getSubseqs(\$sequence,$locs{$seqName});
      printFastA($subSeqs);
      $sequence = '';
    }
    ($seqName) = /$match/o;
    if (not defined $seqName) {
      carp "No match for chromosome name\n\t$_\n";
      $seqName = "NA";
    }
    next;
  }
  next unless (exists $locs{$seqName});
  $sequence .= $_;
}

if (defined $seqName and exists $locs{$seqName}) {
  my $subSeqs = getSubseqs(\$sequence,$locs{$seqName});
  printFastA($subSeqs);
  $sequence = '';
}

sub getSubseqs {
  my $seqRef = shift;
  my @locs = @{shift()};
  my @subseq;
  foreach my $loc (@locs) {
    my $offset = $loc->[1]-1;
    my $length = $loc->[2]-$loc->[1]+1;
    my $name = $loc->[0] . '_' . $loc->[1] . '-' . $loc->[2];
    push @subseq, [$name,substr($$seqRef,$offset,$length)];
  }
  return \@subseq;
}

sub printFastA {
  my $seqArray = shift;
  foreach my $seq (@$seqArray) {
    print ">", $seq->[0], "\n";
    $seq->[1] =~ s/(.{50})/$1\n/g;
    chomp $seq->[1];
    print $seq->[1], "\n";
  }
}
    
__END__

## begin and end coord for probes:
cat  ~/GenomeWideSNP_6.cn.na24.annot.csv|perl  -ne 'next if /^#/; s/\"//g; @F= split /,/;if (/^Probe/) {$F[0]="#ProbeSetID";}  print join (",",@F[0..3]), "\n"' > ~/Affy/GenomeWideSNP_6.cn.na24.annot.loc &

## annotate with gc content;
cat /omm/data/sequence/human_wchr-b36/chr[1-9].fa /omm/data/sequence/human_wchr-b36/chr??.fa /omm/data/sequence/human_wchr-b36/chr[XY].fa |./getGC-contentForLocs.pl -loc ~/Affy/GenomeWideSNP_6.cn.na24.annot.loc >& ~/Affy/GenomeWideSNP_6.cn.na24.annot.GCContent.loc &


### annotate snp probes with gc content: This just uses the flank from the
##  snp probe file.  I don't know the actual probe sequences.  

cat ~/GenomeWideSNP_6.na24.annot.csv|perl  -ne 'next if /^#/; s/\"//g; next if /^Probe/;@F=split /,/; $F[8] = uc ($F[8]);$gc= $F[8]=~tr/GC/GC/; $bases=$F[8]=~tr/ACTG/ACTG/; $ratio="NA"; $ratio=sprintf("%0.2f", $gc/$bases) if $bases; print join(",",@F[0,3,4,4],$ratio),"\n"' > ~/Affy/GenomeWideSNP_6.na24.annot.GCContent.loc &




