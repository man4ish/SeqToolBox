#!/usr/bin/perl -w
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);
use strict;

require_ok ("SeqToolBox::BLASTParser");
my $obj = SeqToolBox::BLASTParser->new( -file => "$FindBin::Bin/opa1_iter.bla", -format => "PGP");
isa_ok($obj, "SeqToolBox::BLASTParser");
isa_ok ($obj, "SeqToolBox::BLAST::BLASTPGP");
#print STDERR "Something", $obj->get_gi_list(),"\n";
my @temp = $obj->get_gi_list();
is($temp[0], "1420493");
is ($temp[$#temp],"49482414");
is (scalar (@temp), 903);