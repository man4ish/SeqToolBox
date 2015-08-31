#!/usr/bin/env perl

##---------------------------------------------------------------------------##
##  File: star_rsem_pipeline.pl
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

star_rsem_pipeline.pl - Run STAR alignment and then run rsem on the alignment. 

=head1 SYNOPSIS

star_rsem_pipeline.pl -f <forward.fq> -r <reverse.fq> --sref <star_reference_genome_dir> --rref <rsem_ref_dir> --tag <string>

=head1 DESCRIPTION

The software runs STAR alignment and RSEM pipeline on the alignment. It cleans up on the intermidiate files keeping only the rsem gene and isoform result files. It appends the tag string given with the --tag option infront of the resulting files. 


The options are:

=over 4

=item -f | --forward <forward fastq file>

The files can be in any compression format. The software will automatically determine the compression and pass the correspoding decompression option to STAR/RSEM.

=item -r | --reverse <reverse fastq file>

The files can be in any compression format. The software will automatically determine the compression and pass the correspoding decompression option to STAR/RSEM.

=item --sref <STAR reference directory>

Star reference database directory.

=item --rref <STAR reference directory>

RSEM reference database directory.

=item -p <Number of processor>

Number of processor to use for the calculation


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
use File::Temp qw(tempdir);
use Cwd;
use Carp;
use Pod::Usage;
use Proc::Background;

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

GetOptions( \%opts, 'help|?', 'forward|f=s', 'reverse|r=s', 'sref=s', 'rref=s',
			'processor|p=n', 'tag|t=s', 'clean_fasta' )
  || pod2usage( -verbose => 0 );

my @fasta_files = @ARGV;
_check_params( \%opts );

my $current_dir   = cwd();
my $unzip_program = get_unzip_program( $opts{'forward'} );
check_programs( 'rsem-calculate-expression', 'STAR' );
my $dir = tempdir( $opts{'tag'} . '.XXXXX', DIR => $current_dir );
chdir($dir) || die "Can't chdir to $dir\n";
system("mkfifo Aligned.toTranscriptome.out.bam") == 0 || die "Could not create mkfifo\n";
my $star = Proc::Background->new("STAR --genomeDir $opts{sref} --readFilesIn ../$opts{forward} ../$opts{reverse} \\
--outFilterType BySJout \\
--outFilterMultimapNmax 20  \\
--outFilterMismatchNmax 999 \\
--alignIntronMin 20   \\
--alignIntronMax 1000000 \\
--alignMatesGapMax 1000000  \\
--alignSJoverhangMin 8 \\
--alignSJDBoverhangMin 1 \\
--quantMode TranscriptomeSAM \\
--runThreadN $opts{processor} \\
--readFilesCommand $unzip_program");
sleep(10);
system("rsem-calculate-expression --no-bam-output --paired-end -p $opts{processor} \\
--bam Aligned.toTranscriptome.out.bam \\
$opts{rref} \\
$opts{tag}") == 0 or die "Can't run RSEM\n";

system ('mv *.results ..') == 0 || die "Could not copy rsem restult\n";
chdir($current_dir);
system ("rm -rf $dir") == 0 || die "Could not remove the temporary dir\n";
if ($opts{clean_fasta}) {
	system("rm -f $opts{forward} $opts{reverse}") == 0 || die "Could not remove fasta files\n";
}
exit(0);

######################## S U B R O U T I N E S ############################

sub check_programs {
	my @programs = @_;
	foreach my $p (@programs) {
		unless ( system("which $p 2>&1 >/dev/null") == 0 ) {
			die "Could not find $p!";
		}
	}
}

sub get_unzip_program {
	my $file = shift;
	if ( $file =~ /\.gz$/ ) {
		return 'zcat';
	} elsif ( $file =~ /\.xz$/ ) {
		return 'xzcat';
	} elsif ( $file =~ /\.bz2$/ ) {
		return 'bzcat';
	} else {
		croak "Could not determine the unzipping program\n";
	}
}

sub _check_params {
	my $opts = shift;
	pod2usage( -verbose => 2 ) if ( $opts->{help} || $opts->{'?'} );
	pod2usage( -verbose => 1 )
	  unless (    $opts->{'forward'}
			   && $opts->{'reverse'}
			   && $opts->{'sref'}
			   && $opts->{'rref'} );
	$opts->{'processor'} || ( $opts->{'processor'} = 8 );
	$opts->{'tag'}       || ( $opts->{'tag'}       = 'tmp' );

}
