#!/usr/bin/perl -w
use strict;

my $cutoff = shift;
my $file = shift;

open (FILE, $file) || die "Can't open $file\n";

while (my $line = <FILE>) {
	next if $line =~ /^\#/;
	my @f = split (/\t/, $line);
	if ($f[10] <= $cutoff) {
		print $line;
	}
}
close FILE;;