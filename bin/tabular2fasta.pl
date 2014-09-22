#!/usr/bin/env perl
# $Id$

##---------------------------------------------------------------------------##
##  File: tabular2fasta.pl
##       
##  Author:
##        Malay <malay@bioinformatics.org>
##
##  Description:
##     
#******************************************************************************
#* Copyright (C) 2012 Malay K Basu <malay@bioinformatics.org> 
#* This work is distributed under the license of Perl iteself.
###############################################################################

=head1 NAME

tabular2fasta.pl - Converts a tab-delimited file to FASTA format.

=head1 SYNOPSIS

tabular2fasta.pl [options] <filename>


=head1 DESCRIPTION

The program coverts a file of following format:

 |----------+------+------+------+------|
 | Position | Seq1 | Seq2 | Seq3 | Seq4 |
 |----------+------+------+------+------|
 |      230 | A    | G    | C    | T    |
 |      231 | C    | T    | G    | T    |
 |      ... | ...  | ...  | ...  | ...  |
 |----------+------+------+------+------|

The first column is the position of the sequence and the subsequent
columns are sequences, but represented virtically. The script
transposes the table and puts the sequences horizontally and creates a
FASTA file.



=head1 OPTIONS 

=over 4

=item B<--header>

Whether the first line is considered to be header.


=back

=head1 COPYRIGHT

Copyright (c) 2012 Malay K Basu <malay@bioinformatics.org>

=head1 AUTHORS

Malay K Basu <malay@bioinformatics.org>

=cut



##---------------------------------------------------------------------------##
## Module dependencies
##---------------------------------------------------------------------------##

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

my $header;

##---------------------------------------------------------------------------##
# Option processing
#  e.g.
#   -t: Single letter binary option
#   -t=s: String parameters
#   -t=i: Number paramters
##---------------------------------------------------------------------------##


my %options = (); # this hash will have the options

#
# Get the supplied command line options, and set flags
#

GetOptions (\%options, 
            'help|?',
            'header') || pod2usage( -verbose => 0 );

_check_params( \%options );

my $file = shift;

die "File doesn't exists:$!" unless -s $file;

my $data;
my @seqnames;

open (FILE, $file) || die "Can't open $file\n";
while (my $line = <FILE>) {
	chomp $line;
	print STDERR "Line $.: $line\n";
	my @f = split (/\t/, $line);
	print STDERR "@f\n";
	if ($. == 1 && $header) {
		shift @f;
		@seqnames = @f;
		next;
	}else {
		print STDERR "Length:", scalar(@f), "\n";
		unless (scalar(@f) == scalar(@seqnames) + 1) {
			die "The number of fields doesn't match in $line\n";
		}
		my $pos = shift @f;
		for (my $i = 0 ; $i < @f; $i++) {
			$data->{$pos}->{$seqnames[$i]} = $f[$i];
		}
	}
	
}
close (FILE);

my @sorted_position = sort {$a <=> $b} keys %{$data};
foreach my $seqname (@seqnames) {
	print "\>$seqname\n";
	my $string ="";
	foreach my $p (@sorted_position) {
		$string .= $data->{$p}->{$seqname};
	}
	print $string, "\n";
}


exit (0);

######################## S U B R O U T I N E S ############################

sub _check_params {
	my $opts = shift;
	pod2usage( -verbose => 2 ) if ($opts->{help} || $opts->{'?'});
#	pod2usage( -verbose => 1 ) unless ( $opts->{'mandetory'});
	if ($opts->{header}) {
		$header = 1;
	}
}
