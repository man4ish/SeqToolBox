#!/usr/bin/perl -w
use strict;

my $input_dir = shift;
my $tree_dir = shift;

opendir (DIR, $input_dir) || die "Can't open $input_dir\n";

while (my $file = readdir(DIR)) {
	next unless $file =~/(\S+)\.dollo\.fas\.phy/;
	my $basename = $1;
	my $fullname = $input_dir.'/'.$file;
	my $treefile = $tree_dir.'/'. $basename.'.fas.aln.tre';
	die "File not found" unless -s $fullname || -s $treefile;
	system ("cp $treefile intree");
	system ("cp $fullname infile");
	`dollop <<END
u
1
4
5
y
END`;
	my $outfile = $basename.'.dollo.out';
	my $outtree = $basename.'.dollo.tre';
	system ("cp outfile $outfile");
	system ("cp outtree $outtree");
	system ("rm infile");
	system ("rm intree");
	system ("rm outfile");
	system ("rm outtree");			
}
close DIR;