#!/usr/bin/env perl
# $Id: load_cdd_parsed_data_in_sqlite.pl 503 2009-08-28 17:58:17Z malay $
##---------------------------------------------------------------------------##
##  File: load_cdd_parsed_data_in_sqlite.pl
##
##  Author:
##        Malay <malay@bioinformatics.org>
##
##  Description:
##     This script loads a already parsed CDD data file to SQlite DB.
##
#******************************************************************************
#* Copyright (C) 2009 Malay K Basu <malay@bioinformatics.org>
#* This work is distributed under the license of Perl iteself.
###############################################################################

=head1 NAME

load_cdd_parsed_data_in_sqlite.pl - Loads parsed CDD datafile to SQLite DB.

=head1 SYNOPSIS

load_cdd_parsed_data_in_sqlite.pl -d <sqlite_db_file> -f <parsed_cdd_data>

=head1 DESCRIPTION

Write a description of your prgram. 

=head1 ARGUMENTS 

=over 4

=item B<--database|-d>

SQLite database file.

=item B<--file|-f>

File to be parsed.

=back

=head1 COPYRIGHT

Copyright (c) 2009 Malay K Basu <malay@bioinformatics.org>

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
use Carp;
use DBI;
use Data::Dumper;

##---------------------------------------------------------------------------##
# Option processing
#  e.g.
#   -t: Single letter binary option
#   -t=s: String parameters
#   -t=i: Number paramters
##---------------------------------------------------------------------------##

my %options = ();    # this hash will have the options

#
# Get the supplied command line options, and set flags
#
GetOptions( \%options, 'help|h', 'database|d=s', 'file|f=s' )
	|| pod2usage( -verbose => 1 );

_check_params( \%options );

my $dbh;
my $dbfile   = $options{database};
my $filename = $options{file};

if ( -s $dbfile ) {
	$dbh = DBI->connect( "dbi:SQLite:dbname=$dbfile", "", "",
						 { AutoCommit => 0, RaiseError => 1 } );
}
else {
	$dbh = DBI->connect( "dbi:SQLite:dbname=$dbfile", "", "",
						 { AutoCommit => 0, RaiseError => 1 } );
	$dbh->do(
		'create table cdhit (
									organism text,
									query text,
									cdd_id text,
									domain text,
									name text,
									e_value numeric,
									length numeric,
									q_start numeric,
									q_end numeric,
									h_start numeric,
									h_end numeric
								)'
	);

	$dbh->do(
		'CREATE TABLE desc (
									cdd_id text, 
									domain text, 
									name text,
									desc text,
									constraint constraint1 unique(cdd_id, domain)
										on conflict ignore
									)'
	);
}

my $sth  = $dbh->prepare('insert into cdhit values(?,?,?,?,?,?,?,?,?,?,?)');
my $sth1 = $dbh->prepare('insert into desc values(?,?,?,?)');
my $organism;

if ( $filename =~ /(\S+)\_parsed\.cdd/ ) {
	my $basename = $1;
	my ( $g, $sp ) = split( /\_/, $basename );

	unless ( $g || $sp ) {
		croak "Could not parse genus and species from filename\n";
	}
	my $G = uc($g);
	$organism = $G . '. ' . $sp;
}
else {
	croak "Filename $filename does not conform to the required spec\n";
}

my $filehandle;

if ($filename =~/\.gz$/) {
	eval {require IO::Uncompress::Gunzip};
	if ($@){ die "Can't load IO::Uncompress::Gunzip";}
	$filehandle = IO::Uncompress::Gunzip->new($filename) or die "Can't open $filename\n";
}elsif ($filename =~ /\.bzip2$/ || $filename =~ /\.bz2$/) {
#	eval {require IO::Uncompress::Bunzip2 }; if ($@) { die "Can't load IO::Uncompress::Bunzip2";}
#	$filehandle = IO::Uncompress::Bunzip2->new("$filename") or die "Can't open $filename\n";
	open $filehandle, "bunzip2 -c $filename |";
}

my $infile;

if ($filehandle) {
	$infile = $filehandle;
}else{

open( $infile, $filename ) || die "Can't open $filename\n";
}

while ( my $line = <$infile> ) {
	chomp $line;
	next if $line =~ /^\#/;
	my (@f) = split( /\t/, $line );
	
#	my ($q, $h, $d_id, $d_name, $p, $l, $q_s, $q_e, $h_s, $h_e, $d) = @f;
	
	print STDERR "@f\n";
	
	if ( @f == 11) {
		my $desc = pop(@f);
		unshift( @f, $organism );
		$sth->execute(@f);
		$sth1->execute( $f[2], $f[3], $f[4], $desc );
	}
	elsif ( @f == 1 ) {

		#unshift (@f, $organism);
		my $query = $f[0];
		$dbh->do(
			"insert into cdhit values (
				'$organism','$query',NULL,NULL,NULL,
				NULL,NULL,NULL,NULL,NULL,NULL)"
		);
	}
}

$sth->finish();
$sth1->finish();
#$dbh->do ('create index index1 on cdhit (organism,query)');
#$dbh->do ('create index index2 on desc (domain)');
$dbh->commit();
$sth  = undef;
$sth1 = undef;
$dbh->disconnect();
if ($filehandle) {close $filehandle;}
exit(0);

######################## S U B R O U T I N E S ############################

sub _check_params {
	my $opts = shift;

	#	print STDERR Dumper($opts), "\n";
	#print STDERR "check params called\n";
	if ( $opts->{help} ) {
		print STDERR "help defined\n";
	}
	pod2usage( -verbose => 2 ) if ( $opts->{help} || $opts->{'?'} );

	#	print STDERR "Before verbose\n";
	#	if ($opts->{'d'}) {
	#		print STDERR $opts->{'d'}, "\n";
	#	}
	pod2usage( -verbose => 1 )
		unless ( $opts->{'database'} || $opts->{'file'} );
}
