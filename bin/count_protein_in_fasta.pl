#!/usr/bin/perl -w
use strict;
my $file = shift;
open (FILE, $file) || die "Can't open $file\n";
my $count = 0;
while (my $line = <FILE>) {
    if ($line =~ /^\#/) {
	next;
    }
    if ($line =~ /^>/) {
	$count++;
    }
}
print "Number of proteins in the file: $count\n";
