#!/usr/bin/env perl
#$Id: fas_fill_defline.pl 84 2007-11-26 19:48:40Z malay $

BEGIN{$^W = 1}
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use SeqToolBox::SeqDB;
use Getopt::Long;

my ($source, $target); # source is the file from wchich defline will be taken
                       # target is the file form which sequenes will be taken


GetOptions ("source=s" => \$source,
			"target=s"=> \$target);

if (!$source && !$target){
	system ("pod2text $0");
	exit (1);
}

my %deflines; ## Use an indexing system later

my $sourceparser = SeqToolBox::SeqDB->new (-file => $source, -format=>"fasta");
my $targetparser = SeqToolBox::SeqDB->new (-file => $target, -format=>"fasta");

while ($sourceparser->has_next){
	my $seq = $sourceparser->next_seq;
	my $gi = $seq->get_gi();
	my $key;
	if ($gi) {
		$key = $gi;
	} else{
		$key = $seq->get_id();
	}
	my $desc = $seq->get_desc();
	$deflines{$key} = $desc;
	#print STDERR $gi,"\t",$desc,"\n";
}

while ($targetparser->has_next){
	my $seq = $targetparser->next_seq();
	my $gi = $seq->get_gi;
	my $key;
	if ($gi) {
		$key = $gi;
	}else{
		$key = $seq->get_id();
	}
	if (!$key){print STDERR "Undefined gi skipping\n";next;}
	if (exists $deflines{$key}){
		$seq->set_desc($deflines{$key});
		print $seq->get_fasta,"\n";
	}else{
		print STDERR "$key not found in source file skipping\n";
		next;
	}
}