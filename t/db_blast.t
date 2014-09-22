#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);
use strict;

my $test_file = File::Spec->catfile($FindBin::Bin,"testdata","test_blast_m9.bla");
my $test_db = File::Spec->catfile ($FindBin::Bin,"testdata","test_blast_m9.db");
unlink($test_db)if (-s $test_db);
require_ok("SeqToolBox::DB::BLASTDB");


my $db = SeqToolBox::DB::BLASTDB->new(-file =>$test_file );
is($db->{_file}, $test_file, "File pass");

my $test_db = File::Spec->catfile ($FindBin::Bin,"testdata","test_blast_m9.db");
#warn ($test_db);
$db = SeqToolBox::DB::BLASTDB->new(-file=>$test_file, -db=>$test_db);
is ($db->{_db}, $test_db, "DB pass");

is ($db->create(),1, "Database create");


my @scores = $db->get_scores (-q => "NT08AB0001", -s=>"NT08AB0659");
is_deeply (\@scores,[26.9], "Score returns");

my @hsps = $db->get_best_hsps("NT08AB0001");
isa_ok ($hsps[0], "SeqToolBox::DB::BLASTHit");
is($hsps[0]->get_query(), "NT08AB0001");

is($hsps[0]->get_subject(), "NT08AB0001");

is($hsps[0]->get_score(), 858);


unlink($test_db)if (-s $test_db);

