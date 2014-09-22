#!/usr/bin/env perl
#$ENV{^W} = 1;

use IO::File;
use IO::Uncompress::AnyUncompress;

use strict;
my $file = shift;

my $input_file_handle;

if ($file) {
	if ( $file =~ /\.gbk\.gz$/ || $file =~ /\.gbk\.bz2$/ ) {
		$input_file_handle
			= IO::Uncompress::AnyUncompress->new( $file, MultiStream => 1 );
	}
	else {
		$input_file_handle = IO::File->new( $file, "r" )
			or die "Can't open filehandle\n";
	}

	#open ($input_file_handle, $file) || die "Can't open $file\n";
}
else {
	$input_file_handle = \*STDIN;
}
my $fh;

while ( my $line = <$input_file_handle> ) {

	if ( $line =~ /^LOCUS\s+(\S+)\s+/ ) {
		my $outfile = $1 . '.gbk';
		if ($fh) { die "Something wrong with filehandle\n"; }
		$fh = IO::File->new();
		$fh->open(">$outfile");

		#open (OUTFILE, ">$outfile") || die "Can't open $outfile\n";
		#$fh = \*OUTFILE;
		print $fh $line;
	}
	elsif ( $line =~ /^\/\// ) {

		#print STDERR "Here\n";
		unless ($fh) { die "Something wrong with filehandle\n"; }
		print $fh $line;
		$fh->close();
		$fh = undef;
	}
	else {

		#print STDERR $line,"\n";

		chomp $line;

		if ($line) {
			if ( !defined($fh) ) {
				print STDERR "last\n";
				die "Something wrong with filehandle\n";
			}
			print $fh $line, "\n";
		}
	}
}

close($input_file_handle);
