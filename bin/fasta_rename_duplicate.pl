#!/usr/bin/perl -w
use strict;

my $file = shift;
open (FILE, $file) || die "Can't open $file\n";

my %seen;
my $dup = 0;
my $entry = 0;
while (my $line = <FILE>) {
    if ($line =~ /^>(\S+)\s+(.*)/) {
	my $id = $1;
	my $rest = $2;
	$entry++;
	if (exists ($seen{$id})) {
	    print STDERR "Duplicates found for $id\n";
	    $dup++;
	    my $last_id = $seen{$id};
	    $id .= '_'.$last_id;
	    print '>'.$id .' '.$rest,"\n";
	    $seen{$id}++;
	}else {
	    print $line;
	    $seen{$id}++;
	}
	
    }else {
	print $line;
    }
}

close FILE;
print STDERR "$dup found of $entry\n";
