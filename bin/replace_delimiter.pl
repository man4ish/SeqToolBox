#!/usr/bin/perl -w
use strict;

my $dir = shift;
my $source_delimiter = shift;
my $target_delimiter = shift;

opendir(DIR, $dir) || die "Can't open $dir\n";
$dir =~ s/\/$//;
while (my $file = readdir (DIR)) {
	next if -d $file;
	my $full_name = $dir .'/'.$file;
	#$file =~ /(.*)\.(.*)/;
	my $outfile = '~'.$file;
	open (FILE, $full_name) || die "Can't open $full_name\n";
	open (OUT, ">$outfile") || die "Can't open $outfile to write\n";
	while (my $line = <FILE>){
		$line =~ s/$source_delimiter/$target_delimiter/g;
		print OUT $line;
	}
	close OUT;
	close FILE;
	if (-s $file){
		unlink $file;
		
	}
	system ("mv $outfile $file") == 0
		or die "Can't rename $outfile to $file: $?";
}

close DIR;