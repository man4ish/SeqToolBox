#!/usr/bin/perl -w
use FindBin;
use lib "$FindBin::Bin/../lib";
use File::Spec;
use strict;
use Test::More ("no_plan");

require_ok("SeqToolBox::SeqDB::FASTAIndex");
my $test_db = File::Spec->catfile( $FindBin::Bin, "test_fasta_index.idx" );

if ( -s $test_db ) {
	unlink $test_db || croak("Could not remove test index db");
}
my $index = SeqToolBox::SeqDB::FASTAIndex->new( -file => $test_db );
isa_ok( $index, "SeqToolBox::SeqDB::FASTAIndex", "Object test" );

#Put some data
$index->create();
$index->insert( -id => 'a', -pos => '10' );
$index->insert( -id => 'b', -pos => '20' );
$index->create_index();
$index->commit();

#test retrieval
is( 10, $index->get_pos('a'), "Position A" );
is( 20, $index->get_pos('b'), "Position B" );

#test duplicate entry
$index->insert(-id=>'a', -pos =>30);

#test retrieval
my @pos = $index->get_all_pos('a');
is_deeply (\@pos,[10,30], "Multiple positions");

is( 10, $index->get_pos('a'), "Position A" );


unlink $test_db || croak("Could not remove test index db");

