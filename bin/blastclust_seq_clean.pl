#!/usr/bin/perl -w

# $Id: blastclust_seq_clean.pl 48 2007-09-14 16:31:36Z malay $
# This software takes a blastclust output file and takes the first
# column out of it and retrieves these sequences out of a fasta file.

#  Usage: blast_clust_seq_clean.pl <blastclust output> <fasta_file>

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use SeqToolBox::SeqDB;

my $bc_file = shift;
my $fa_file = shift;

open (BC, $bc_file) || die "Can't open $bc_file\n";

my %hash;

while (my $line = <BC>){
    chomp $line;
    my @flds = split (/\s+/, $line);
    $hash{$flds[0]} = 1;
}

close (BC);

my $seqdb = SeqToolBox::SeqDB->new(-file=>"$fa_file");
while ($seqdb->has_next){
	my $seq = $seqdb->next_seq();
	my $id = $seq->get_id();
	if ($id =~ /gi\|(\d+)\|/) {
		my $gi = $1;
		if (exists $hash{$gi}){
			print $seq->get_fasta(),"\n";
		}
	}
}


#open (FA, $fa_file) || die "Can't open $fa_file\n";
#
#my $lastseq     = "";
#my $lastgi      = "";
#my $total_seq   = 0;
#my $written_seq = 0;
#my $line_num = 0;
#
##my $lastdefline;
#
#while ( my $line = <FA> ) {
#    my $line_num++;
#    if ( $line =~ /^>/ ) {
#        $total_seq++;
#        if ($lastgi) {
#	    if (exists $hash{$lastgi}) {
#		print $last_seq;
#	    }
#            $written_seq++;
#            $lastseq = $line;
#            if ($line =~ /gi\|(\d+)\|/){
#            $lastgi = $1;
#           # $lastgi =~ s/[^0-9A-Za-z]/\_/g;
#
#            #	$lastdefline = $line;
#	}else {
#	    die "ERR: No gi found on line $line_num";
#            $last_gi = undef;
#	}  
#        }
#        else {
#            $lastseq = $line;
#            $line =~ /^(\S+)/;
#            $lastgi = $1;
#            $lastgi =~ s/[^0-9A-Za-z]/\_/g;
#
#        }
#    }
#    else {
#        $lastseq .= $line;
#    }
#}
#
#if ($lastgi) {
#    my $outfile = $lastgi . '.fas';
#    open( OUTFILE, ">$outfile" ) || die "Can't open $outfile\n";
#    print OUTFILE $lastseq;
#    close(OUTFILE);
#    $written_seq++;
#
### Please see file perltidy.ERR
#    #	$lastseq = $line;
#    #		$line =~ /^>(\S+)/;
#    #		$lastgi = $1;
#    #		$lastgi =~ s/[^0-9A-Za-z]/\_/g;
#
#}
#
#
#sub get_clean_gi {
#    my $gi = shift;
#    
#}
