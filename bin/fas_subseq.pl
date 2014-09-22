#!/usr/bin/env perl
#$Id: fas_subseq.pl 83 2007-11-21 23:59:37Z malay $
BEGIN { $^W = 1 }
use FindBin;
use lib "$FindBin::Bin/../lib";
use SeqToolBox::SeqDB;
use SeqToolBox::Seq;
use Getopt::Long;

my ( $start, $end, $format );
GetOptions(
			"start=i" => \$start,
			"end=i"   => \$end,
			"format"  => \$format
);

unless ( $start || $end ) {
	system("pod2text $0");
	exit(1);
}

#
#
#
#
#my $id;
#my $desc;
#my $seq = "";
#my $found = 0;
#while (my $line = <STDIN>){
#	chomp $line;
#	next unless $line;
#	if ($line =~ /^>(\S+)\s+(.*)/) {
#		$id = $1;
#		$desc = $2;
#		$found = 1;
#	}elsif ($found == 1){
#		$line =~ s/\s+//g;
#		$seq .= $line;
#
#	}else {
#
#	}
#
#}

my $file = shift;

my $seqdb = SeqToolBox::SeqDB->new( -file => $file );
while ( my $seq = $seqdb->next_seq() ) {
	my $subseq = $seq->get_aln_subseq (-start => $start, -end => $end);
	#my $seqobj = SeqToolBox::Seq->new( -id => $id, -desc => $desc, -seq => $seq );    
	#my $subseq = $seqobj->get_subseq( -start => $start, -end => $end );

	if ($format) {
		print SeqToolBox::Seq->new( -id => $seq->get_id(), 
									-desc => $seq->get_desc(),
									-seq => $subseq )->get_fasta();
		print "\n";
	}
	else {
		print $subseq,"\n";
	}
}
