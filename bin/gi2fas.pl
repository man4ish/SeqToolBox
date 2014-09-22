#!/usr/bin/env perl
BEGIN { $^W = 1 }

# $Id:gi2fas.pl 22 2007-08-03 17:28:24Z malay $

##---------------------------------------------------------------------------##
##  File: gi2fas.pl
##
##  Author:
##        Malay <malay@bioinformatics.org>
##
##  Description:
##
#******************************************************************************
#* Copyright (C) 2007 Malay K Basu <malay@bioinformatics.org>
#* This work is distributed under the license of Perl iteself.
###############################################################################

=head1 NAME

gi2fas.pl - Write your description here

=head1 SYNOPSIS

gi2fas.pl <option1> <option2> ...

=head1 DESCRIPTION

The options are:

=over 4

=item <first option>

=item <second option>

=back


=head1 SEE ALSO

=head1 COPYRIGHT

Copyright (c) 2007 Malay K Basu <malay@bioinformatcs.org>

=head1 AUTHORS

Malay K Basu <malay@bioinformatics.org>

=cut

##---------------------------------------------------------------------------##
## Module dependencies
##---------------------------------------------------------------------------##

use FindBin;
use lib "$FindBin::Bin/../lib";
use NCBIWeb;
use strict;
use Getopt::Long;
use SeqToolBox::SeqDB;

my @opts    = qw(help seqdb=s exclude);    # declare your options here
my %options = ();                          # this hash will have the options

#
# Get the supplied command line options, and set flags
#

_parse_options( \%options, \@opts );

# Print the internal POD documentation if something is missing

if ( $#ARGV == -1 && !$options{'help'} || $options{'help'} ) {
	print "No options";

	# This is a nifty trick so we don't have to have
	# a duplicate "USAGE()" subroutine.  Instead we
	# just recycle our POD docs.  See PERL POD for more
	# details.

	exec "pod2text $0";
	die;
}

my $WEB      = 0;
my $filename = shift;

#print STDERR $ARGV[0], $ARGV[1],"\n";
my $fh;
my %gilist;

if ( !exists $options{'seqdb'} ) {

	#print STDERR "Getting sequences from web\n";
	$WEB = 1;
}

if ( $filename eq '-' ) {

	#$parser = SeqToolBox::BLASTParser->new(-fh=>\*STDIN,-format=>'pgp');
	$fh = \*STDIN;
} else {

	#$parser = SeqToolBox::BLASTParser->new(-file=>$filename,-format=>'pgp');
	$fh = IO::File->new( $filename, "r" );
}

my $count = 0;

while ( my $line = <$fh> ) {
	chomp $line;
	unless ( $line =~ /^(\d+)$/ ) {
		die "GI has to be number given $line\n";
	}
	$gilist{$line} = ++$count;
}

if ($WEB) {
	my $web = NCBIWeb->new();
	foreach my $line ( sort { $gilist{$a} <=> $gilist{$b} } keys %gilist ) {

		#while ( my $line = <$fh> ) {
		#	chomp $line;
		print $web->get_protein_seq( -gi => $line, -format => 'fasta' ), "\n";
	}

} else {
	my $parser = SeqToolBox::SeqDB->new( -file   => $options{seqdb},
										 -format => 'FASTA' );
	while ( $parser->has_next ) {
		my $seq = $parser->next_seq();
		my $id  = $seq->get_id();
		$id =~ /gi\|(\d+)\|/;
		my $gi = $1;
		if ( $gi && exists( $gilist{$gi} ) ) {
			if ( $options{exclude} ) {
				next;
			} else {
				print $seq->get_fasta(), "\n";
			}
		}
	}
}

if ( $filename ne '-' ) {
	$fh->close();
}

exit(0);

######################## S U B R O U T I N E S ############################

sub _parse_options {
	unless ( GetOptions( $_[0], @{ $_[1] } ) ) {
		exec "pod2text $0";
		exit(0);
	}
}
