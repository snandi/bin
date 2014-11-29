#!/usr/bin/perl -w 

eval 'exec /usr/bin/perl -w  -S $0 ${1+"$@"}'
    if 0; # not running under some shell

#setting new path directory of /omm/lib/perl/lib/site_perl/5.6.0/
use lib "/omm/lib/perl/lib/site_perl/5.6.0/";

#
# $Source: /home/opgen/cvs/mapdb/bin/mapset.pl,v $
# $Revision: 1.4 $
# $Date: 2004/01/20 17:46:42 $
#
# Please read the COPYRIGHT file and associated LICENSE file.
#

=head1 NAME

mapset.pl - like LMCG mapset, but doesn't talk to a database


=head1 SYNOPSIS

./mapset.pl mapset.maps

=head1 DESCRIPTION

Usage: mapset.pl <.maps file 'A'> [options]

   -count                 : return number of maps
   -w <.maps file>        : write mapset to file
   -u <.maps file 'B'>    : 'set Union' of mapsets (A U B)
   -i <.maps file 'B'>    : 'set Intersection' of mapsets (A ^ B)
   -not <.maps file 'B'>  : 'set Not' of mapsets (A not B)
   -min <size>            : enforce minimum molecule size

=cut

use strict;
use warnings;

require MapDB::MapData::MapSet;

use Getopt::Long;

my $union=0;
my $intersect=0;
my $write=0;
my $not=0;
my $count_only=0;
my $min=0;

GetOptions(
  'count' => \$count_only,
  'u=s' => \$union,
  'i=s' => \$intersect,
  'w=s' => \$write,
  'not=s' => \$not,
  'min=n' => \$min,
);


#
# Read mapset data data from the mapset data file
#

(scalar(@ARGV) == 1) || 
  die("
Usage: mapset.pl <.maps file 'A'> [options]

   -count                 : return number of maps
   -w <.maps file>        : write mapset to file
   -u <.maps file 'B'>    : 'set Union' of mapsets (A U B)
   -i <.maps file 'B'>    : 'set Intersection' of mapsets (A ^ B)
   -not <.maps file 'B'>  : 'set Not' of mapsets (A not B)
   -min <size>            : enforce minimum molecule size

");
my $query_set = load_maps($ARGV[0]);


if( $union )
{
  my $mapset = load_maps($union);
  $query_set->add( $mapset->maps() );
}

if( $intersect )
{
  my $mapset = load_maps($intersect);
  foreach ($query_set->ids)
  {
    $query_set->remove($_) unless defined $mapset->map($_);
  }
}

if( $not )
{
  my $mapset = load_maps($not);
  $query_set->remove( $mapset->ids );
}

if( $write )
{
  $query_set->write($write);
}

if ($min)
{
  foreach ($query_set->maps)
  {
    $query_set->remove($_->id) unless $_->size > $min;
  }
}

my @query_maps = $query_set->maps();

if( $count_only )
{
  print scalar(@query_maps) . "\n";
  exit 0;
}


#
# Gather statistics regarding the maps in the mapset
#

my $total_fragments = 0;
my $total_length = 0.0;
my $min_l = 10000000000000000;
my $max_l = 0.0;
my $number_maps  = scalar(@query_maps);

foreach my $map (@query_maps) {
  my $fragments = $map->fragments();

  $total_fragments += $map->number_fragments();
  my $length = $map->size;
  $total_length += $length;
  $min_l = $length if $length < $min_l; 
  $max_l = $length if $length > $max_l; 
}

my $ave_length = $total_length / $number_maps;
my $ave_fragments = $total_fragments / $number_maps;


print"
Total Size:                     " . $total_length/1000 ." Mb
Number of Molecules:            $number_maps 
Average Size of Molecules:      $ave_length kb
Maximum molecule size:          $max_l kb
Minimum molecule size:          $min_l kb

Number of Fragments:            $total_fragments 
Average Size of Fragments:      " . $total_length/$total_fragments . " kb
Average # of Frags/Molecule:    $ave_fragments frags/mol
\n";

exit(0);


sub load_maps
{
  my $file = shift;
  my $rvalue = MapDB::MapData::MapSet->new();
  $rvalue->read($file); 
  return $rvalue;
} 


exit(0);
