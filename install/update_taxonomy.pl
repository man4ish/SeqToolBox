#!/usr/bin/env perl
BEGIN { $^W = 1 }

# $Id: update_taxonomy.pl 717 2014-01-13 23:25:00Z malay $

##---------------------------------------------------------------------------##
##  File: update_taxonomy.pl
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

##---------------------------------------------------------------------------##
## Module dependencies
##---------------------------------------------------------------------------##

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use SeqToolBox;
use Getopt::Long;
use Term::ProgressBar;
use URI;
use LWP::UserAgent;
use DBI;
use Archive::Tar;
use Archive::Extract;
use IO::Zlib;

#use Smart::Comments;
use Carp;
use File::Spec;
use File::Path;

my $NCBI       = "ftp://ftp.ncbi.nih.gov/pub/taxonomy/";
my $TAXDUMP    = "taxdump.tar.gz";
my $TAXID_NUCL = "gi_taxid_nucl.dmp.gz";
my $TAXID_PROT = "gi_taxid_prot.dmp.gz";
my $DELNODES   = "delnodes.dmp";
my $MERGED     = "merged.dmp";

#
my $db = SeqToolBox->new()->get_dbdir();
my $taxdb = File::Spec->catfile( $db, 'taxonomy' );
mkpath($taxdb);
print STDERR "Using $taxdb as storage...\n";

#
#unless ( -d $taxdb ) {
#	system("mkdir $taxdb");
#}
#

my $LOCAL_TAXID_PROT = File::Spec->catfile( $taxdb, $TAXID_PROT );
download( $LOCAL_TAXID_PROT, $NCBI, $TAXID_PROT );
print STDERR "Unzipping $LOCAL_TAXID_PROT\n";

#my $fh = IO::Zlib->new( $LOCAL_TAXID_PROT, "rb" );
#create_db( $fh, "gi_taxid_prot.dmp", [ "gi", "tax_id" ], [ 0, 1 ], ["gi"] );
#close($fh);
Archive::Extract->new( archive => $LOCAL_TAXID_PROT )->extract( to => $taxdb );
system("rm $LOCAL_TAXID_PROT");
my $LOCAL_TAXID_INPUT_FILE = File::Spec->catfile( $taxdb, "gi_taxid_prot.dmp" );
create_db( "", "gi_taxid_prot.dmp", [ "gi", "tax_id" ], [ 0, 1 ], ["gi"] );
system("rm $LOCAL_TAXID_INPUT_FILE") == 0
  or die "Can't remove $LOCAL_TAXID_INPUT_FILE\n";

my $LOCAL_TAXDUMP = File::Spec->catfile( $taxdb, $TAXDUMP );
download( $LOCAL_TAXDUMP, $NCBI, $TAXDUMP );
print STDERR "Unzipping $LOCAL_TAXDUMP\n";

my $archive = Archive::Tar->new($LOCAL_TAXDUMP);
$archive->extract_file( "nodes.dmp",
						File::Spec->catfile( $taxdb, "nodes.dmp" ) );
my $fh = IO::File->new( File::Spec->catfile( $taxdb, "nodes.dmp" ) );
create_db( $fh, "nodes.dmp",
		   [ "tax_id", "parent_tax_id", "rank", "division_id" ],
		   [ 0,        1,               2,      4 ],
		   [ "tax_id", "parent_tax_id" ] );
close($fh);

$archive->extract_file( "names.dmp",
						File::Spec->catfile( $taxdb, "names.dmp" ) );

$fh = IO::File->new( File::Spec->catfile( $taxdb, "names.dmp" ) );
create_db( $fh, "names.dmp",
		   [ "tax_id", "name", "unique_name", "name_class" ],
		   [ 0,        1,      2,             3 ],
		   ["tax_id"] );

#create_db( "", "names.dmp",
#		   [ "tax_id", "name", "unique_name", "name_class" ],
#		   [ 0,        1,      2,             3 ],
#		   ["tax_id"] );

close($fh);
system("rm $LOCAL_TAXDUMP") == 0 or die "Can't remove $LOCAL_TAXDUMP\n";
my $LOCAL_TAXDUMP_INPUTFILE = File::Spec->catfile( $taxdb, "nodes.dmp" );
system("rm $LOCAL_TAXDUMP_INPUTFILE") == 0
  or die "Can't remove $LOCAL_TAXDUMP_INPUTFILE\n";
$LOCAL_TAXDUMP_INPUTFILE = File::Spec->catfile( $taxdb, "names.dmp" );
system("rm $LOCAL_TAXDUMP_INPUTFILE") == 0
  or die "Can't remove $LOCAL_TAXDUMP_INPUTFILE\n";

#$archive->extract_file ('delnodes.dmp', File::Spec->catfile($taxdb, "delnodes.dmp"));
#$archive->extract_file('merged.dmp'), File::Spec->catfile($taxdb,"merged.dmp");

#my $dbname;
#my $dbh;
#my $sth;
#my $file;
#my $sql;
#
#my $file = "names.dmp";
#$archive->extract($file);
#$dbname = $taxdb.'/names.db';
#
#
#$sql = qq(create table names(tax_id,name_txt,unique_name,name_class) );
#$dbh->do($sql);
#$sth = $dbh->prepare(qq(insert into names (tax_id,name_txt,unique_name,name_class) values (?,?,?,? )));
#populate_tables($dbh, $sth, $file,[0,1,2,3] );
#unlink ("names.dmp");
#
#my $dbh->disconnect;
#
#$archive->extract("nodes.dmp");
#
#$dbname = $taxdb.'/nodes.db';
#
#if (-s $dbname) {unlink $dbname};
#
#$dbh = DBI->connect("dbi:SQLite:dbname=$dbname","","", {RaiseError=>1, AutoCommit=>0});
#$sql = qq(create table nodes(tax_id,parent_tax_id,rank,division_id) );
#$dbh->do($sql);
#$sth = $dbh->prepare(qq(insert into nodes (tax_id,parent_tax_id,rank,division_id) values (?,?,?,? )));
#
#populate_tables($dbh, $sth, "nodes.dmp",[0,1,2,4] );

sub download {
	my ( $file, $website, $remote_file ) = @_;
	my $path = $website . $remote_file;
	print STDERR "$path\n";
	open my $outfile, ">$file" || die "Can't create $file: $!";

	print STDERR "Downloading Taxonomy file from NCBI website.\n";
	my $bar = Term::ProgressBar->new(
							{ name => $file, count => 1024, ETA => 'linear' } );
	my $output        = 0;
	my $target_is_set = 0;
	my $next_so_far   = 0;

	my $ua = LWP::UserAgent->new();
	$ua->get(
		$path,
		":content_cb" => sub {
			my ( $chunk, $response, $protocol ) = @_;

			unless ($target_is_set) {
				if ( my $cl = $response->content_length ) {
					$bar->target($cl);
					$target_is_set = 1;

				} else {
					$bar->target( $output + 2 * length $chunk );
				}
			}
			$output += length $chunk;

			#print STDERR $chunk;
			print $outfile $chunk;

			if ( $output >= $next_so_far ) {
				$next_so_far = $bar->update($output);
			}

		}
	);

	$bar->target($output);
	$bar->update($output);

	close $outfile;

}

sub create_db {
	my ( $fh, $file, $field_names, $col_index, $indexes ) = @_;

	#$archive->extract($file);
	$file =~ /(\S+)\.dmp/;
	my $base          = $1;
	my $dbname        = File::Spec->catfile( $taxdb, $base . '.db' );
	my $fullinputfile = File::Spec->catfile( $taxdb, $file );
	if ( -s $dbname ) { unlink $dbname }
	my $dbh = DBI->connect( "dbi:SQLite:dbname=$dbname", "", "",
							{ RaiseError => 1, AutoCommit => 0 } );
	my $sql =
	  'create table ' . $base . '(' . join( ",", @{$field_names} ) . ')';
	print STDERR $sql, "\n";
	$dbh->do($sql);

	if ($fh) {
		my $num = scalar( @{$field_names} );
		$sql =
		    'insert into '
		  . $base . '('
		  . join( ",", @{$field_names} )
		  . ') values('
		  . join( ",", split( //, "?" x $num ) ) . ')';
		print STDERR $sql, "\n";
		my $sth = $dbh->prepare($sql);
		populate_tables( $fh, $dbh, $sth, $file, $col_index );
		$dbh->commit();
		$sth->finish;
		$sth = undef;

		$dbh->disconnect;
	} else {
		$dbh->commit();
		$dbh->disconnect;

		print STDERR "Direct import: Creating $dbname\n";
		`sqlite3 $dbname << ENDINPUT
.separator \\t
\.import $fullinputfile $base
\.quit
ENDINPUT`;
	}

	print STDERR "After disconnect\n";

	if ($indexes) {
		my $dbh = DBI->connect( "dbi:SQLite:dbname=$dbname", "", "",
								{ RaiseError => 1, AutoCommit => 0 } );
		$sql =
		    'create index index1 on '
		  . $base . '('
		  . join( ",", @{$indexes} ) . ')';
		print STDERR "$sql\n";
		$dbh->do($sql);
		$dbh->commit();
		$dbh->disconnect;

		#		$dbh->commit();
	}

	#	print STDERR "$sql\n";
	#	my $sth1 = $dbh->prepare($sql);
	#	$sth1->execute();

	#	$sth->finish;
	#	$sth = undef;
	#	$sth1->finish;
	#	$sth1 = undef;

	#unlink $file;
}

sub populate_tables {
	my ( $fh, $d, $s, $file, $col ) = @_;

	#open my $fh, "$file" or die "Can't open $file: $!";
	my $count = 0;
	print STDERR "Loading...";

	while ( my $line = <$fh> ) {
		chomp $line;
		my @f;

		if ( $line =~ /\|/ ) {
			$line =~ s/\|$//;
			@f = split( /\|/, $line );
		} else {
			@f = split( /\t/, $line );
		}
		my @values;

		foreach my $i (@f) {
			$i =~ s/^\s+//;
			$i =~ s/\s+$//;
			my $v = $i ? $i : "";
			push @values, $i;
		}
		my @required;

		foreach my $i ( @{$col} ) {
			if ( defined $values[$i] ) {
				push @required, $values[$i];
			} else {
				die "Required col missing in table $file\n";
			}
		}

		#print STDERR "@required\n";
		$s->execute(@required);

		#		if ( $count >= 50000 ) {
		#			$d->commit();
		#			$count = 0;
		#		}
		#		else {
		#			$count++;
		#		}

	}
	print STDERR "done.\n";

	#	$d->commit;

	#close ($fh);
}

#$dbh->disconnect();

__END__


=head1 NAME

update_taxonomy.pl - Write your description here

=head1 SYNOPSIS

update_taxonomy.pl <option1> <option2> ...

=head1 OPTIONS

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
# Option processing
#  e.g.
#   -t: Single letter binary option
#   -t=s: String parameters
#   -t=i: Number paramters
##---------------------------------------------------------------------------##

#my @opts = qw( ); # declare your options here
#my %options = (); # this hash will have the options
#
##
## Get the supplied command line options, and set flags
##
#
#_parse_options (\%options, \@opts);
#
#
## Print the internal POD documentation if something is missing
#
#if ( $#ARGV == -1 && !$options{'help'} ) {
#  #print "No options";
#
#  # This is a nifty trick so we don't have to have
#  # a duplicate "USAGE()" subroutine.  Instead we
#  # just recycle our POD docs.  See PERL POD for more
#  # details.
#  
#  exec "pod2text $0";
#  die;
#}
#
#
#
#exit (0);
#
######################### S U B R O U T I N E S ############################
#
#sub _parse_options {
#	unless ( GetOptions ($_[0], @{$_[1]} )) {
#		exec "pod2text $0";
#		exit (0);
#	}
}
