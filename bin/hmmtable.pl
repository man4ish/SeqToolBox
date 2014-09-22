#!/usr/bin/env perl
#$Id:$

##---------------------------------------------------------------------------##
##  File: hmmtable.pl
##
##  Author:
##  	Malay <malay@bioinformatics.org>
##
##  Description:
##
##   The script takes the result of the hmmer3 domain table file (--domtbl
##   option of hmmscan) and converts it into the format as provided by PFAM
##   proteome distribution. Script require PFAM domain data file.
##   --------------------------------------------------------------------------##

#******************************************************************************
#* Copyright (C) 2014 Malay K Basu <malay@bioinformatics.org>
#* This work is distributed under the license of Perl iteself.
###############################################################################

=head1 NAME

hmmtable.pl - Converts a hmmer result file (domain table) to same format as
distributed by the "proteome" files in PFAM.

=head1 SYNOPSIS

	hmmtable.pl --dat=<PFAM data file> <PFAM result file>
	hmmtable.pl --dat=<PFAM data file>

=head1 DESCRIPTION

The script takes the PFAM data file
(ftp://ftp.sanger.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.dat.gz) as
an option. It reads the HMMER3 hmmscan result from a file or from the STDIN. And
generates a tab-delimited file with the following columns:

	#<seq id> <alignment start> <alignment end> <envelope start> <envelope end>
	<hmm acc> <hmm name> <type> <hmm start> <hmm end> <hmm length> <bit score>
	<E-value> <clan>


=head1 OPTIONS

=over 4

=item --dat|d file

The absolute path to PFAM data file. You don't need to unzip this file.

=back


=head1 ARGUMENTS

=over 4

=item <file>

The absolute path to HMMER3 hmmscan table. This is not the hmmscan output
file. This is file gerated using --domtbl option. If the file argument is
missing, the script will try to read the file from STDIN.

=back

=head1 SEE ALSO

=head1 COPYRIGHT

Copyright (c) 2014 Malay K Basu <malay@bioinformatcs.org>

=head1 AUTHORS

Malay K Basu <malay@bioinformatics.org>

=cut

##---------------------------------------------------------------------------##
## Module dependencies
##---------------------------------------------------------------------------##

use strict;
use Getopt::Long;
use FindBin;
use lib "$FindBin::Bin/../lib";
use SeqToolBox::Pfam::Data;
use SeqToolBox::File;
use Pod::Usage;

##---------------------------------------------------------------------------##
## Globals
##---------------------------------------------------------------------------##

my $pfam_data;    # Hash containing various data from PFAM dat file

##---------------------------------------------------------------------------##
# Option processing
#  e.g.
#   -t: Single letter binary option
#   -t=s: String parameters
#   -t=i: Number paramters
##---------------------------------------------------------------------------##

my @options = ( "help|h", "data|d=s" );    # declare your options here
my %opts = ();                             # this hash will have the options

#
# Get the supplied command line options, and set flags
#

_parse_options( \%opts, \@options );

my $hmm_file = $ARGV[0];
exec "pod2text $0" unless $hmm_file;




# Parse the PFAM dat file
$pfam_data = SeqToolBox::Pfam::Data->new( $opts{data} )
  || die "Could not create the data file obj\n";



# Print the header line
print join(
	"\t",
	"#seq id",       "seq_length",     "alignment_start",
	"alignment_end", "envelope_start", "envelope_end",
	"hmm_acc",       "hmm_name",       "type",
	"hmm_start",     "hmm_end",        "hmm_length",
	"bit_score",     "E-value",        "clan"
  ),
  "\n";




# Main loop
my $file = SeqToolBox::File->new($hmm_file);
my $fh   = $file->get_fh();

while ( my $line = <$fh> ) {
	next if $line =~ /^\#/;
	chomp $line;
	my @f           = split( /\s+/, $line );
	my $domain_type = $pfam_data->get_domain_type_from_acc( $f[1] );
	my $domain_clan = $pfam_data->get_clan_from_acc( $f[1] );
	$domain_clan = "No_clan" unless $domain_clan;

	#my $domain_len = $pfam_data->get_length_from_acc( $f[1] );
	die "Could not find domain type or accession for $f[1]\n"
	  unless ( $domain_type || $domain_clan );
	print join( "\t",
				$f[3],  $f[5], $f[17], $f[18],       $f[19],
				$f[20], $f[1], $f[0],  $domain_type, $f[15],
				$f[16], $f[2], $f[13], $f[12],       $domain_clan ),
	  "\n";
}

$file->close();







sub _parse_description {
	my $data_file = shift;
	die "Could not find file $data_file\n" unless ( -f $data_file );
	my $fh;

	if ( $data_file =~ /\.gz$/ ) {
		open( $fh, "gzip -c -d -f $data_file|" )
		  || die "Could not open $data_file using gzip filter\n";
	} elsif ( $data_file =~ /\.bzip2$/ ) {
		open( $fh, "bzip2 -c -d -f $data_file|" )
		  || die "Could not open $data_file using bzip2 filter\n";
	} else {
		open( $fh, "$data_file" ) || die "Could not open $data_file\n";
	}

}

## Print the internal POD documentation if something is missing
#
#if ( $#ARGV == -1 || $options{'help'} ) {
#	print "No options";
#
#	# This is a nifty trick so we don't have to have
#	# a duplicate "USAGE()" subroutine.  Instead we
#	# just recycle our POD docs.  See PERL POD for more
#	# details.
#
#	exec "pod2text $0";
#	die;
#}
#
#exit(0);

######################## S U B R O U T I N E S ############################

sub _parse_options {
	GetOptions( $_[0], @{ $_[1] } ) or pod2usage(2);
	pod2usage(1) if $opts{help};
}
