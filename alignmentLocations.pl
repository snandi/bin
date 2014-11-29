#!/usr/bin/perl -w

#### match frag index for ref and aligned nMaps to look at correlation between fluor intensity and GC
##     content.

##  This produces a list of pairs of frag indices;

### copied from ~teague/scripts/stuff/get_alignment_stats.pl 5/30/2012
##  modified to eliminate small frags.

use strict;
use warnings;
use Carp;
use English;
use Getopt::Long;
use File::Basename;
use FileHandle;
use vars qw($VERSION);

$VERSION = '0.8';

use FindBin qw($Bin);
#use lib "$Bin/lib";
use lib '/omm/bin/lib';

require SOMA;
($SOMA::VERSION eq $VERSION) || die("$0: Could not find SOMA v$VERSION\n");

my $minFragSize = 0;
my $xmlFileList;

GetOptions (
	    'minFragSize=f'   => \$minFragSize,
	    'xmlFileList=s'   => \$xmlFileList,
	    );

my @xmlFiles = ();
if (defined $xmlFileList) {
  open XML, $xmlFileList or
    croak "Can't read $xmlFileList";
  while (<XML>) {
    chomp;
    s/#.*$//;
    next if /^\s*$/;
    push @xmlFiles, $_;
  }
  close XML;
}
else {
  @xmlFiles = @ARGV;
}


my $num_cuts_expected = 0;
my $skippedOnRef = 0;
my $skippedOnOp  = 0;

my $num_missing_cuts = 0;
my $num_extra_cuts = 0;

my %alignmentChunksFor;

foreach my $file (@xmlFiles) {
  if (not -s $file) {
    carp "Empty or non-existant file: $file: skipping...";
    next;
  }
  my $xml = SOMA::MapData::ParseXML->parse( $file);
  my $ref_mapset = $xml->mapset('consensus');
  my $opt_mapset = $xml->mapset('opmap');
  my $alignment_set = $xml->alignmentset();

  for( my $i = 0; $i < $alignment_set->size(); $i++ )
    {
      my $alignment = $alignment_set->alignment($i);
      my $ref_map = $ref_mapset->map_by_id( $alignment->id1() );
      my $ref_id = $ref_map->id();
      my $op_map = $opt_mapset->map_by_id( $alignment->id2() );
      my $op_id = $op_map->id();

      if ($alignment->orientation1() != 1) {
	carp "This ref map is flipped!\n",
	  join(",", $op_id,$ref_id,$alignment->orientation2()), "\n";
      }

      ### used for calculating the lengths of the aligned sections of
      ##   the ref map and nMap, which is then used to estimate molecule
      ##   stretch (or conversion factor);
      my $alignmentStart;
      my $alignmentEnd;
      my @chunks;
      foreach my $j (0..$alignment->nchunks()-1) {
	my ($start1, $start2, $end1, $end2, $match) = $alignment->chunk($j);
	next if ($match eq '');  ## this is a gap

	if (not defined $alignmentStart) {
	  ## is this right for 
	  $alignmentStart = [
			     $ref_map->cut_offset($start1),
			     $op_map->cut_offset($start2)
			    ];
	}
	$alignmentEnd = [
			 $ref_map->cut_offset($end1),
			 $op_map->cut_offset($end2)
			];



	#push @{$alignmentChunksFor{$chr}},
	## refID refStartIndex refEndIndex opID opStartIndex opEndIndex refStartCoor refEndCoord opStartCoor opEndCoord orient lengthRatio
	push @chunks,
	  [
	   $ref_id,$start1,$end1,
	   $op_id,$start2,$end2,

	   $ref_map->cut_offset($start1),$ref_map->cut_offset($end1),
	   $op_map->cut_offset($start2),$op_map->cut_offset($end2),

	   $alignment->orientation2(),
	  ];
      } ## foreach $j (looping through alignment chunks)
      my $alignmentLength = [ 
			     abs($alignmentEnd->[0] - $alignmentStart->[0]),
			     abs($alignmentEnd->[1] - $alignmentStart->[1])
			     ];
      ## lengthRatio = ref length/nMap length;
      my $lengthRatio = $alignmentLength->[0]/$alignmentLength->[1];
      map {push @$_, $lengthRatio} @chunks;
      (my $chr = $ref_id) =~s/^chr//;
      push @{$alignmentChunksFor{$chr}},@chunks;
			   
    } ## for alignment_set (looping through alignments)
} ## while @xmlFiles



## could be foreach my $i (1..22,'X','Y') {
##                next unless (exists $alignmentChunksFor{chr$i}); etc...
foreach my $chr(sort keys %alignmentChunksFor) {
  my @chunks = @{$alignmentChunksFor{$chr}};
  @chunks = sort{$a->[1]<=> $b->[1]} @chunks;
  map{print join("\t",@$_),"\n"} @chunks;
}

__END__

Add length of the nMap (or approx3 nPixels in fluor intensity) and num frags to table 
  because the stretch may depend on length.

Change this to delete molecules with multiple alignments --- multiple alignments may be enriched for errors.
For example, copies of a seg dup might diff in GC content.



frags with missing punctates:   no problem--use same intensity for both frags;
frags with extra punctates:  could average over the frags or skip.
          skip is easier.
