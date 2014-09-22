#!/usr/bin/perl -w

#$Id:reformat_fas.pl 22 2007-08-03 17:28:24Z malay $

# The script takes a FASTA file
# and reformats the sequence with capitalized first chracter of genus
# and two characters of species name appended with the gi number.

use FindBin;
use lib "$FindBin::Bin/../lib";
use SeqToolBox;
use SeqToolBox::SeqDB;

use strict;

my $file = shift;

#open( FILE, $file ) || die "Can't open $file\n";
#my %hash;
#my $linenum = 0;
#
##my $last_seq = "";
#while ( my $line = <FILE> ) {
#	$linenum++;
#	if ( $line =~ /^>(\S+)/ ) {
#		my $s       = $1;
#		my $last_gi = "";
#		if ( $s =~ /gi\|(\d+)/ ) {
#			$last_gi = $1;
#			if ( exists( $hash{$last_gi} ) ) {
#				die "Duplicate $last_gi found on line $linenum\n";
#			}
#			else {
#				$hash{$last_gi} = 1;
#			}
#		}
#		else {
#			$last_gi = $s;
#		}
#
#		if ( $line =~ /\[(.+)\]/ ) {
#			my $name   = $1;
#			my $string = "";
#
#			if ($name) {
#				my ( $g, $s ) = split( /\s+/, $name );
#				$string .= substr( $g, 0, 1 );
#				$string .= substr( $s, 0, 2 );
#			}
#
#			$last_gi = '>' . $string . '_' . $last_gi;
#			print $last_gi, "\n";
#		}
#		else {
#			print $line;
#		}
#	}
#
#}

my $seqdb = SeqToolBox::SeqDB->new (-file=> $file);
while ($seqdb->has_next()){
	my $seq = $seqdb->next_seq();
	my $id = $seq->get_id();
	my $gi;
	if ($id =~ /gi\|(\d+)\|/ ) {
		$gi = $1;
	}else {
		$gi = $id;
	}
	my $des = $seq->get_desc();
	my $genus;
	my $sp;
	#my $subsp;
	my $s = "";
	if ($des =~ /\[(.*)\]/ ) {
		my @s = split (/\s+/, $1);
		$genus = shift (@s);
		$sp = shift (@s);
		$s .= substr($genus, 0,3);
		$s .= substr($sp, 0, 2);	
	}else {
		next;
	}
	print ">$s\_$gi $des\n";
	print $seq->get_pretty_seq(),"\n";
}