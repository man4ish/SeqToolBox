#!/usr/bin/perl -w
use strict;
use lib "/home/mbasu/bin/projects/SeqToolBox/lib";

use SeqToolBox::Alignment;

my $dir = shift;
my $cutoff = shift;

$cutoff = $cutoff/ 100;

opendir (DIR, $dir) || die "Can't open $dir\n";

while (my $file = readdir (DIR)) {
	next unless $file =~ /\.aln$/;
	my $fullname = $dir .'/'. $file;
	my $align = SeqToolBox::Alignment->new (-file => $fullname, -format => 'FASTA');
	my $align_length = $align->length();
	my $proper = 1;
	while (my $seq = $align->next_seq()) {
		my $seq_length = length($seq->get_ungapped_seq());
		if ( ($seq_length/$align_length) < $cutoff ) {
			$proper = 0;
			last;
		}
	}
	if ($proper) {
		system ("cp $fullname .");
	}
}

close (DIR);
