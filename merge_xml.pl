#!/usr/bin/perl -w 
#
# $Source: /gnomm/src/CVS/gnomm/soma/bin/merge_xml.pl.in,v $
# $Revision: 1.2 $
# $Date: 2005/11/15 16:24:20 $
#
# Please read the COPYRIGHT file and associated LICENSE file.
#

=head1 NAME

merge_xml.pl - Merge XML files and output by chromosome

=head1 SYNOPSIS

./merge_xml.pl
  [--help]                      - print help and exit
  [--quiet]                     - do not print progress information
  [--chromosome]                - sort output by chromosome
  [--match='Hs([^_]+)_']        - regular expression to extract chromosome
  [--output='file-XX.xml.gz']   - output file template
  [--minscore=0.0]              - filter alignments less than this score
  [--minchunk=0]                - filter alignments shorter than this length
  [--mincount=0]                - filter alignments having fewer than this
                                       number of aligned fragments
  [--sort]                      - sort output alignments by starting location

  [--linearfit= Thresh,Slope]   - use a linear fit to filter by score/nfrag.
    
                                  The formula to filter is as follows:
                                  Score > = Thresh - Slope * (aligned frags)

                                  Any alignments satisfying the equation
                                  above will be kept.
                     
    
    
  align1.xml.gz align2.xml.gz   - input XML files

./merge_xml.pl --help
./merge_xml.pl --output=merged.xml.gz align1.xml.gz align2.xml.gz
./merge_xml.pl --chromosome --output=human-XX.xml.gz align*.xml.gz

=head1 DESCRIPTION

The merge_xml.pl script reads alignment data from a collection of XML
files and merges the alignments.  If run with the --chromosome option,
the output files are sorted by chromosome.  If sorting by chromosome,
then the --match option specifies how to extract the chromosome number
from the mapset name.  The output file is specified with the --output
flag.  If generating chromosomes, then the pattern 'XX' in the output
file name is replaced with the chromosome number.

If the --sort option is given, then the output alignments are sorted
by their starting location on the reference genome.  This option is
useful for viewing alignments in genspect.  However, using the --sort
option dramatically increases memory usage, since all the input maps
and alignments must be stored in memory to be sorted.  If merging large
sets with --chromosome and --sort, it might make sense to first merge
by --chromosome and then --sort each of the chromosome files.

=cut

use strict;
use warnings;
use vars qw($VERSION);

$VERSION = '0.8';

use FindBin qw($Bin);
use lib "$Bin/lib";

require File::Basename;
require Getopt::Long;
require SOMA;

($SOMA::VERSION eq $VERSION) || die("$0: Could not find SOMA v$VERSION\n");

#
# Parse the command line arguments
#

my $help       = 0;
my $quiet      = 0;
my $chromosome = 0;
my $match      = 'Hs([^_]+)_';
my $outputfile = undef;
my $minscore   = 0;
my $minchunk   = 0;
my $mincount   = 0;
my $dosort     = 0;
my @linearFit  = ();
Getopt::Long::GetOptions(
			 'help'       => \$help,
			 'quiet'      => \$quiet,
			 'chromosome' => \$chromosome,
			 'match=s'    => \$match,
			 'output=s'   => \$outputfile,
			 'minscore=f' => \$minscore,
			 'mincount=i' => \$mincount,			 
			 'minchunk=i' => \$minchunk,
			 'sort'       => \$dosort,
			 'linearfit=s'=> \@linearFit
			) || usage();

usage() if (($help) || (scalar(@ARGV) == 0));

if (!defined($outputfile)) {
  if ($chromosome) {
    $outputfile = 'merged-XX.xml.gz';
  } else {
    $outputfile = 'merged.xml.gz';
  }
}

## allow option as a comma-separated list or as two entries on the cmd line.
@linearFit = split(/,/, join(',',@linearFit));


#
# Parse each of the input XML files and output the results as we go along
#

my $outxml = { };
foreach my $file (@ARGV) {
  print "Processing '$file'...\n" if (!$quiet);
  parse_and_write($outxml, $file, $quiet);
}

#
# If sorting, then we need to sort the cached alignments and write.
#

if ($dosort) {
  foreach my $stream (keys(%{$outxml})) {
    foreach my $contig (keys(%{$outxml->{$stream}->{'alignments'}})) {
      my $alignments = $outxml->{$stream}->{'alignments'}->{$contig};
      my @sorted = sort {
        ($a->{'align'}->cutpair(0))[0] <=> ($b->{'align'}->cutpair(0))[0]
      } @{$alignments};
      foreach (@sorted) {
        $outxml->{$stream}->{'xml'}->write_alignment(
          $_->{'align'},
          $_->{'refmap'},
          $_->{'optmap'}
        );
      }
    }
  }
}

#
# Close each of the output streams and exit
#

foreach (keys(%{$outxml})) {
  $outxml->{$_}->{'xml'}->close();
}

exit(0);

#
# Output script usage end exit.  Bye bye.
#

sub usage {
  print STDERR <<EOF;
$0
  [--help]                      - print help and exit
  [--quiet]                     - do not print progress information
  [--chromosome]                - sort output by chromosome
  [--match='Hs([^_]+)_']        - regular expression to extract chromosome
  [--output='file-XX.xml.gz']   - output file template
  [--minscore=0.0]              - filter alignments less than this score
  [--minchunk=0]                - filter alignments shorter than this length
  [--mincount=0]                - filter alignments having fewer than this
                                       number of aligned fragments
					   
  [--linearfit= Thresh,Slope]   - use a linear fit to filter by score/nfrag.
    
                                  The formula to filter is as follows:
                                  Score > = Thresh - Slope * (aligned frags)

                                  Any alignments satisfying the equation
                                  above will be kept.
					   
  [--sort]                      - sort output alignments by starting location
  align1.xml.gz align2.xml.gz   - input XML files

./merge_xml.pl --help
./merge_xml.pl --output=merged.xml.gz align1.xml.gz align2.xml.gz
./merge_xml.pl --chromosome --output=human-XX.xml.gz align*.xml.gz
EOF
  exit(1);
}

#
# Parse the specified XML file and output the alignments
#

sub parse_and_write {
  my $outxml = shift;
  my $file   = shift;
  my $quiet  = shift;

  my $xml = SOMA::MapData::ParseXML->parse($file);
  my $metadata = $xml->metadata();
  my $refmaps  = $xml->mapset('consensus');
  my $optmaps  = $xml->mapset('opmap');
  my $alignset = $xml->alignmentset();

  for (my $i = 0; $i < $alignset->size(); $i++) {
    my $align = $alignset->alignment($i);
    my $ref   = $align->id1();
    my $opt   = $align->id2();

    next if ($align->score() < $minscore);
    next if ($align->nmatches() < $minchunk);
    next if ($align->count() < $mincount);

    #if linear fit is set check that the alignment is above the line
    if (@linearFit) {
      next unless (linearFit($align));
    }
    
    #
    # Find the appropriate output stream
    #

    my $stream = "default";
    if ($chromosome) {
      ($stream) = ($ref =~ /$match/);
      (defined($stream) && ($stream ne ''))
        || die("$0: Unknown chromosome number in map '$ref'\n");
    }

    #
    # If the output stream does not yet exist, then create it
    #

    if (!exists($outxml->{$stream})) {
      my $filename = $outputfile;
      if ($chromosome) {
        my ($n,$p,$s) = File::Basename::fileparse($filename, ".xml", ".xml.gz");
        if ($n =~ /XX/) {
          $n =~ s/XX/$stream/;
        } else {
          $n .= "-$stream";
        }
        $filename = $p . $n . $s;
      }
      print "Writing '$filename'...\n" if (!$quiet);
      $outxml->{$stream} = {
        filename   => $filename,
        refmaps    => { },
        optmaps    => { },
        alignments => { },
        xml        => SOMA::MapData::GentigXML->open($filename, %{$metadata})
      };
    }

    #
    # Write the map information (if needed) and the alignment
    #

    my $refmap = $refmaps->map_by_id($ref);
    my $optmap = $optmaps->map_by_id($opt);

    if (!$outxml->{$stream}->{'refmaps'}->{$ref}) {
      $outxml->{$stream}->{'xml'}->write_map($refmap, type => "consensus");
      $outxml->{$stream}->{'refmaps'}->{$ref} = 1;
    }
    if (!$outxml->{$stream}->{'optmaps'}->{$opt}) {
      $outxml->{$stream}->{'xml'}->write_map($optmap, type => "opmap");
      $outxml->{$stream}->{'optmaps'}->{$opt} = 1;
    }
    if (!$dosort) {
      $outxml->{$stream}->{'xml'}->write_alignment($align, $refmap, $optmap);
    } else {
      if (!defined($outxml->{$stream}->{'alignments'}->{$ref})) {
        $outxml->{$stream}->{'alignments'}->{$ref} = [ ];
      }
      push(@{$outxml->{$stream}->{'alignments'}->{$ref}}, {
        align  => $align,
        refmap => $refmap,
        optmap => $optmap
      });
    }
  }
}

#
# this subroutine takes the alignment, score, and number of fragments of
# the aligned map and returns 1 if the alignment exceeds the linear fit
# parameters set via the linearFit[0] and linearFit[1] variables set
# by the user via the -linearfit flag
#
# $retval = linearFit($align,$score,$numfrags);
#
sub linearFit {
  my $align = shift;
  my $score = $align->score();
  my $count = $align->count();

  if ( $score  >= $linearFit[0]- $linearFit[1]*$count ) {
    return 1;
  }
  else {
    return 0;
  }
}

