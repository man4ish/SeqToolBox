#!/usr/bin/perl -w

#This program takes a fasta file and split the file into several files each containing one sequence.

# Usage: splitfasta.pl <filename>

use strict;
use Getopt::Std;
die "Usage: splitfasta.pl <filename>\n" unless $ARGV[0];
our (%opt);

#open( INFILE, $ARGV[0] ) || die "Can't open $ARGV[0]\n";
getopt( 's:', \%opt );

my $split = $opt{s}? $opt{s} :1;

my $lastseq     = "";
my $lastgi      = "";
my $total_seq   = 0;
my $written_seq = 0;

#my $lastdefline;

my $file = shift;
open( INFILE, $file ) || die "Can't open $file\n";

if ( $split == 1 ) {
	while ( my $line = <INFILE> ) {
		if ( $line =~ /^>/ ) {
			$total_seq++;

			if ($lastgi) {
				my $outfile = $lastgi . '.fas';
				open( OUTFILE, ">$outfile" ) || die "Can't open $outfile\n";
				print OUTFILE $lastseq;
				close(OUTFILE);
				$written_seq++;
				$lastseq = $line;
				$line =~ /^>(\S+)/;
				$lastgi = $1;
				$lastgi =~ s/[^0-9A-Za-z]/\_/g;

				#	$lastdefline = $line;

			} else {
				$lastseq = $line;
				$line =~ /^>(\S+)/;
				$lastgi = $1;
				$lastgi =~ s/[^0-9A-Za-z]/\_/g;

			}
		} else {
			$lastseq .= $line;
		}
	}

	if ($lastgi) {
		my $outfile = $lastgi . '.fas';
		open( OUTFILE, ">$outfile" ) || die "Can't open $outfile\n";
		print OUTFILE $lastseq;
		close(OUTFILE);
		$written_seq++;

## Please see file perltidy.ERR
		#	$lastseq = $line;
		#		$line =~ /^>(\S+)/;
		#		$lastgi = $1;
		#		$lastgi =~ s/[^0-9A-Za-z]/\_/g;

	}
}

if ( $split > 1 ) {
	while ( my $line = <INFILE> ) {
		if ( $line =~ /^>/ ) {
			$total_seq++;

			#			print STDERR $total_seq%$opt{s},"\n";
			if ( $total_seq != 1 && !( ( $total_seq - 1 ) % $split ) ) {

				#				print STDERR $line, "\n";
				my $outfilename = $lastgi . '.fas';
				open( OUTFILE, ">$outfilename" )
				  || die "Can't open $outfilename\n";
				print OUTFILE $lastseq;
				close(OUTFILE);
				$written_seq++;
				$lastseq = "";
				$lastgi  = "";
			}

			if ($lastgi) {

			   #				$outfilename = $TEMP_DIR . '/' . $lastgi . '.lsf';
			   #				open( OUTFILE, ">$outfile" ) || die "Can't open $outfile\n";
			   #				print OUTFILE $lastseq;
			   #				close(OUTFILE);

				$lastseq .= $line;
				$line =~ /^>(\S+)/;
				$lastgi = $1;
				$lastgi =~ s/[^0-9A-Za-z]/\_/g;

			} else {
				$lastseq = $line;
				$line =~ /^>(\S+)/;
				$lastgi = $1;
				$lastgi =~ s/[^0-9A-Za-z]/\_/g;

			}
		} else {
			$lastseq .= $line;
		}
	}

	if ($lastgi) {
		my $outfile = $lastgi . '.fas';
		open( OUTFILE, ">$outfile" ) || die "Can't open $outfile\n";
		print OUTFILE $lastseq;
		close(OUTFILE);
		$written_seq++;

		#	$lastseq = $line;
		#		$line =~ /^>(\S+)/;
		#		$lastgi = $1;
		#		$lastgi =~ s/[^0-9A-Za-z]/\_/g;
	}

}
close(INFILE);

print STDERR "$total_seq sequences found in the file\n";
print STDERR "$written_seq files written\n";
