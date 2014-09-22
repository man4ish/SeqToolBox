#!/usr/bin/env perl
BEGIN{$^W =1}

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use SeqToolBox::SeqDB;
use SeqToolBox::Taxonomy;
my $file = shift;

my $seqdb = SeqToolBox::SeqDB->new (-file=> $file);
my $tax = SeqToolBox::Taxonomy->new();
while ($seqdb->has_next()){
	my $seq = $seqdb->next_seq();
	my $id = $seq->get_id();
	my $gi;
	if ($id =~ /gi\|(\d+)\|/ ) {
		$gi = $1;
	}elsif ($id =~ /^(\S+)\_(\d+)/) {
		$gi = $2;
		
	}else {
		$gi = $id;
	}
	my $des = $seq->get_desc();
#	my $genus;
#	my $sp;
#	#my $subsp;
#	my $s = "";
#	if ($des =~ /\[(.*)\]/ ) {
#		my @s = split (/\s+/, $1);
#		$genus = shift (@s);
#		$sp = shift (@s);
#		$s .= substr($genus, 0,3);
#		$s .= substr($sp, 0, 2);	
#	}else {
#		next;
#	}
#	
	my $div = $tax->classify($gi);
	if ($div) {
		my @c = split (//,$div);
		print ">",uc($c[0]),'_',$id," $des\n";
	}else{
		print ">*_",$id." $des\n";
	}
	#print ">$s\_$gi\n";
	print $seq->get_pretty_seq(),"\n";
}

