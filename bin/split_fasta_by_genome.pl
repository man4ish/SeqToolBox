#!/usr/bin/env perl
# $Id: split_fasta_by_genome.pl 678 2012-02-08 00:06:36Z malay $
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use SeqToolBox::Taxonomy;
use SeqToolBox::SeqDB;

my $file = shift;

my $taxonomy = SeqToolBox::Taxonomy->new();
my $seqdb = SeqToolBox::SeqDB->new (-file => $file);

while (my $seq = $seqdb->next_seq()) {
	my $gi = $seq->get_gi();
	unless ($gi) {
		die "Gi not found in " . $seq->get_desc();	
	}
	my $taxon = $taxonomy->get_taxon($gi);
	unless ($taxon) {
		print STDERR "Taxon not found for $gi... trying...";
		my $desc = $seq->get_desc();
		if ($desc =~ /taxonId=(\d+)/) {
			$taxon = $1;
			print STDERR "found $taxon\n";
		}
	}
	unless ($taxon) {
		print STDERR  "Could not find taxon for $gi skipping \n";
		next;	
	}
	
	my $outfile_name = "$taxon".'.fas';
	open (my $outfile, ">>$outfile_name") || die "Can't open $outfile_name\n";
	print $outfile $seq->get_fasta();
	close ($outfile);
}
