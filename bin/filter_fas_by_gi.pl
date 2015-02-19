#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/../lib/";
use SeqToolBox::SeqDB;
use SeqToolBox::Seq;
use Getopt::Long;
use strict;
use warnings;

my %opts = ();     
GetOptions( \%opts, 
			'help|?',
			'file|f=s') || pod2usage( -verbose => 0 );

my %gi;
open (FILE, $opts{file}) || die "Can't open $opts{file}\n";
while (my $line = <FILE>) {
	chomp $line;
	$gi{$line} = 1;
}
close (FILE);
my $file = shift;
my $seqdb = SeqToolBox::SeqDB->new(-file => $file);

while (my $seq = $seqdb->next_seq) {
	my $id = $seq->get_gi();
	unless ($id) {
		$id = $seq->get_id();
		
		
	}
	
	unless ($id) {
		die "Could not parse id from seq\n";
	}
#	my $id = $seq->get_id();
	if (exists $gi{$id}) {
		#print STDERR "Duplicate found for $id\n";
		#next;
	
#	my $def = $seq->get_desc();
	#print $id,"\n";
	#print $def,"\n";
	
#	my $cleaned_seq = $seq->get_cleaned_seq();
#	my $newseq;
#	if ($def) {
		#print "defined\n";
#		$newseq = SeqToolBox::Seq->new(-id => $id, -des=>$def, -seq=>$cleaned_seq);
#	}else{
#		$newseq = SeqToolBox::Seq->new(-id=>$id, -seq=>$cleaned_seq);
#	}
	print $seq->get_fasta();
	}
#	$seen{$id} = 1;	
	#die "";
}
