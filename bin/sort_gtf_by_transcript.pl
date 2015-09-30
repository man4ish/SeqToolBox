#!/usr/bin/perl -w
use strict;
use warnings;

my $file = shift;
open(FILE, $file) || die "Can't open $file\n";

my %whole_file;
while (my $line = <FILE>) {
	#print $line;
	if ($line =~ /transcript_id\s+\"(\S+)\"/) {
		#print STDERR $line;
		if (exists $whole_file{$1}) {
			push @{$whole_file{$1}}, $line;
		}else {
			$whole_file{$1} = [$line];
		}
	}	
}

close (FILE);

foreach my $i (sort keys %whole_file) {
	foreach my $j ( @{ $whole_file{$i} } ) {
		print $j;
	}
}