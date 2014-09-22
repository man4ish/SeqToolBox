#!/usr/bin/env perl
#$Id: pretty_fas.pl 48 2007-09-14 16:31:36Z malay $

BEGIN{$^W =1}

use FindBin;
use  lib "$FindBin::Bin/../lib";
use SeqToolBox::SeqDB;

my $file = shift;
die "No filename mentioned" unless $file;

my $db = SeqToolBox::SeqDB->new (-file => $file, -format=>'fasta');
while ($db->has_next){
	my $seq = $db->next_seq();
	print $seq->get_fasta,"\n";
}

