#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);
use strict;

require_ok("SeqToolBox::Alignment");

my $align = SeqToolBox::Alignment->new(-file => "t/KOG0077.wir", -format=>"fasta");
isa_ok($align, "SeqToolBox::Alignment");
isa_ok($align, "SeqToolBox::SeqDB");
is ($align->seq_count, 3);
is ($align->length, 1050);
ok($align->is_flush);

my @con = $align->get_ungapped_positions();
#print STDERR "@con\n";

my $align2 = SeqToolBox::Alignment->new(-file => "$FindBin::Bin/test.fas.aln", -format=>"fasta");
isa_ok ($align2, "SeqToolBox::Alignment");
is($align2->length, 960);
my $slice = $align2->slice(22,24);
is($slice->get_seq_by_index(0)->get_seq(), "MSA");
is ($slice->get_seq_by_index(1)->get_seq(),"MAI");
is ($slice->get_seq_by_index(2)->get_seq(),"LGI");
is($slice->length, 3);
#print STDERR 

$slice = $align2->slice(21,24);
@con = $slice->get_ungapped_positions();
#print "@con\n";
is_deeply(\@con,[2,3,4]);

$slice = $align2->slice(957,960);
@con = $slice->get_ungapped_positions();
#print "@con\n";
is_deeply(\@con,[1,4]);
#print "@con\n";

is ($align2->get_column_as_string(960), "QQQ");
is ($align2->get_column_as_string(1), "--M");