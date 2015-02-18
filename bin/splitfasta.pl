#!/usr/bin/perl -w

#This program takes a fasta file and split the file into several files each containing one sequence.

# Usage: splitfasta.pl <filename>

use strict;
use Getopt;
die "Usage: splitfasta.pl <filename>\n" unless $ARGV[0];
our (%opt);
#open( INFILE, $ARGV[0] ) || die "Can't open $ARGV[0]\n";
getopt('s:', \%opt);

$opt{s} = 1 unless $opt{s};

my $lastseq     = "";
my $lastgi      = "";
my $total_seq   = 0;
my $written_seq = 0;

#my $lastdefline;

my $file = shift;
open (INFILE, $file ) || die "Can't open $file\n";

if ($opt{s} == 1) {
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

        }
        else {
            $lastseq = $line;
            $line =~ /^>(\S+)/;
            $lastgi = $1;
            $lastgi =~ s/[^0-9A-Za-z]/\_/g;

        }
    }
    else {
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

if ($opt{s} > 1 ) {

    
}

print STDERR "$total_seq sequences found in the file\n";
print STDERR "$written_seq sequences written\n";
