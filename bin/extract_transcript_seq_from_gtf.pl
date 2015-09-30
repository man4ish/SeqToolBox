#!/usr/bin/env perl

##---------------------------------------------------------------------------##
##  File: extract_transcript_seq_from_gtf.pl
##
##  Author:
##        Malay <malay@bioinformatics.org>
##
##  Description:
##
#******************************************************************************
#* Copyright (C) 2015 Malay K Basu <malay@bioinformatics.org>
#* This work is distributed under the license of Perl iteself.
###############################################################################

=head1 NAME

extract_transcript_seq_from_gtf.pl - extract transcript sequence in fasta format given a gtf and a genome fasta file.

=head1 SYNOPSIS

extract_transcript_seq_from_gtf.pl -gtf <gtf_file> <genme_fasta_file> ...

=head1 DESCRIPTION

The options are:

=over 4

=item -gtf FILENAME

The gtf file

=item <genome_fasta_file>

=back


=head1 SEE ALSO

=head1 COPYRIGHT

Copyright (c) 2015 Malay K Basu <malay@bioinformatcs.org>

=head1 AUTHORS

Malay K Basu <malay@bioinformatics.org>

=cut

##---------------------------------------------------------------------------##
## Module dependencies
##---------------------------------------------------------------------------##

use strict;
use warnings;
use Getopt::Long;
use FindBin;
use lib "$FindBin::Bin/../lib";
use SeqToolBox::SeqDB;
use SeqToolBox::Seq;
use Carp;
use Carp::Assert;

##---------------------------------------------------------------------------##
# Option processing
#  e.g.
#   -t: Single letter binary option
#   -t=s: String parameters
#   -t=i: Number paramters
##---------------------------------------------------------------------------##

my %opts = ();    # this hash will have the options

#
# Get the supplied command line options, and set flags
#

GetOptions( \%opts, 'help|?', 'gtf=s', ) || pod2usage( -verbose => 0 );

my $fasta_file = $ARGV[0];
_check_params( \%opts );

my $seqdb = SeqToolBox::SeqDB->new( -file => $fasta_file );
my %last_seq_obj;
my $data;
my %strand_info;

open( FILE, $opts{"gtf"} ) || croak "Could not open $opts{gtf}\n";

my $old_transcript;
my @old_start = ();
my @old_end   = ();
my $old_strand;
my $old_chr;
while ( my $line = <FILE> ) {
	chomp $line;
	my @f = split( /\t/, $line );
	next unless $f[2] eq "CDS";
	my $transcript = get_transcript( $f[8] );
	assert($transcript);
	my $start  = $f[3];
	my $end    = $f[4];
	my $strand = $f[6];
	my $chr    = $f[0];
	assert( $start <= $end );
	$data->{$chr}->{$transcript}->{$start}->{$end} = 1;
	$strand_info{$transcript} = $strand;

#	if (defined($old_transcript) && $old_transcript ne $transcript) {
#		if (my $return = extract_seq ($old_transcript, \@old_start, \@old_end, $old_strand, $old_chr)) {
#			@old_start = ();
#			@old_end = ();
#		}else {
#			next;
#		}
#
#	} elsif (defined($old_transcript)) {
#		assert ($old_strand eq $strand);
#		assert ($old_transcript eq $transcript);
#		assert ($old_chr eq $chr);
#	}else {
#
#	}
#
#	$old_transcript = $transcript;
#	$old_strand = $strand;
#	$old_chr = $chr;
#	push @old_start, $start;
#	push @old_end, $end;
}

extract_seq();

exit(0);

######################## S U B R O U T I N E S ############################
sub get_transcript {
	my $info = shift;
	if ( $info =~ /transcript_id\s+\"(\S+)\"/ ) {
		return $1;
	} else {
		return undef;
	}
}

sub extract_seq {
	foreach my $c ( sort keys %{$data} ) {
		my $seq = $seqdb->get_seq_by_id($c);
		unless ($seq) {
			warn "Could not extract sequence $seq";
			next;
		}
		foreach my $t ( keys %{ $data->{$c} } ) {
			my $seq_string = "";
			foreach my $s ( sort { $a <=> $b } keys %{ $data->{$c}->{$t} } ) {
				foreach my $e ( keys %{ $data->{$c}->{$t}->{$s} } ) {
					$seq_string .= $seq->get_subseq( -start => $s, -end => $e );

					#print STDERR join("\t", $t, $s, $e), "\n";
				}
			}
			my $outseq = SeqToolBox::Seq->new();
			$outseq->set_seq($seq_string);
			$outseq->set_id($t);
			if ( $strand_info{$t} eq "-" ) {
				my $rev = $outseq->revcom();
				$outseq->set_seq($rev);
			}
			print $outseq->get_fasta();
		}

	}
}

#sub extract_seq {
#	my ($t, $s, $e, $strand, $c) = @_;
#	if (!exists($last_seq_obj{$c}) ) {
#		my $temp = $seqdb->get_seq_by_id($c);
#		unless ($temp) {
#			warn "Could not extract sequence fro $c\n";
#			return undef;
#		}
#		$last_seq_obj{$c} = $temp;
#	}
#	my $seq = $last_seq_obj{$c};
#	my $seq_string = "";
#	for (my $i = 0; $i < scalar(@{$s}); $i++) {
#		$seq_string .= $seq->get_subseq(-start => $s->[$i], -end => $e->[$i]);
#	}
#	my $outseq = SeqToolBox::Seq->new();
#	$outseq->set_seq($seq_string);
#	$outseq->set_id($t);
#	if ($strand eq "-") {
#		my $rev = $outseq->revcom();
#		$outseq->set_seq($rev);
#	}
#	print $outseq->get_fasta(), "\n";
#	return 1;
#
#}

sub _check_params {
	my $opts = shift;
	pod2usage( -verbose => 2 ) if ( $opts->{help} || $opts->{'?'} );
	pod2usage( -verbose => 1 ) unless ( $opts->{'gtf'} );
}
