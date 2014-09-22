use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);
use strict;
use File::Spec;

#use Data::Dumper;
use Carp;

my $datafile =
  File::Spec->catfile( $FindBin::Bin, "testdata", "Pfam-A.hmm.dat.gz" );

die "Could not find Pfam dat file" unless -f ($datafile);

#print STDERR $datafile, "\n";
require_ok("SeqToolBox::Pfam::Data");

my $obj = SeqToolBox::Pfam::Data->new($datafile);

#print Dumper($obj);
is( "ZZ", $obj->get_id_from_acc("PF00569.12"), "get_id_from_acc" );

is( $obj->get_des_from_acc("PF00569.12"),
	'Zinc finger, ZZ type',
	"get_des_from_acc" );

is( $obj->get_domain_type_from_acc("PF00569.12"),
	"Domain", "get_domain_type_from_acc" );

is( "ZYG-11_interact", $obj->get_id_from_acc("PF05884.7"), "get_id_from_acc" );

is( $obj->get_des_from_acc("PF05884.7"),
	'Interactor of ZYG-11',
	"get_des_from_acc" );
is( $obj->get_domain_type_from_acc("PF05884.7"),
	"Family", "get_domain_type_from_acc" );

is( $obj->get_clan_from_acc("PF09723.5"), "CL0167", "get_clan_from_acc" );

is( $obj->get_clan_from_acc("PF00172.13"), undef, "get_clan_from_acc" );
