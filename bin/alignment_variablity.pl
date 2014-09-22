#!/usr/bin/env perl
use strict;
use SeqToolBox::SeqDB;
use SeqToolBox::Alignment;
use File::Basename;
my $dir = shift;
while (my $file = glob("$dir/*.aln")) {
	my ($base, $dir, $suff) = fileparse($file,".aln");
	next unless $suff;
	my $align = SeqToolBox::Alignment->new(-file=>$file);
	my $length = $align->length();
	my @conservered_position = $align->get_conserved_positions();
	my $num_con_pos = scalar(@conservered_position);
	my $percent_variable = (1 - ($num_con_pos/$length))*100;
	print $base, "\t", $percent_variable, "\n";
}