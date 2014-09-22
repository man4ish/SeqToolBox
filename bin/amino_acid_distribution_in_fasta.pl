#!/usr/bin/env perl
use strict;
use SeqToolBox::SeqDB;

my $file = shift;
my $db = SeqToolBox::SeqDB->new (-file => $file);
my $data;
while (my $seq = $db->next_seq()) {
	my $s = $seq->get_cleaned_seq();
	my @aa = split (//, $s);
	foreach my $i(@aa) {
		$data->{$i}++;
	}
	
}

foreach my $i (sort keys %{$data}) {
	print $i ,"\t", $data->{$i},"\n";
}