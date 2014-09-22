#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);
use strict;

require_ok ("SeqToolBox::DB::BLASTHit");

my $hit = SeqToolBox::DB::BLASTHit->new(-query=>"NT08AB0001", -subject=> "NT08AB2806",-score=>28.9);
isa_ok ($hit, "SeqToolBox::DB::BLASTHit");
is ($hit->get_query, "NT08AB0001", "Query test");
is ($hit->get_subject, "NT08AB2806", "Subject test");
is ($hit->get_score, "28.9", "Score test");