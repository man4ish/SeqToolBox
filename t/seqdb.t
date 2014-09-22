use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

require_ok("SeqToolBox::SeqDB");
my $sdb = SeqToolBox::SeqDB->new(-file=>"$FindBin::Bin/test.fas.aln");
isa_ok($sdb, "SeqToolBox::SeqDB");


my $count = 0;

while ( $sdb->has_next() ) {
	
	$sdb->next_seq()->get_seq();
	$count++;
	#print STDERR $count++,"\n";
}

is($count, 3);

is ($sdb->seq_count, 3);
#
my $first_seq = $sdb->get_seq_by_index(0);
is ($first_seq->get_id, "Ot20g00940");
my $second_seq = $sdb->get_seq_by_index(1);
is($second_seq->get_id,"gi|15241911|ref|NP_198226.1|");
my $third_seq = $sdb->get_seq_by_index(2);

is($third_seq->get_id,"AK101483|Os07g0644300");
#
ok($first_seq->contains_gap());
#
my $sdd = SeqToolBox::SeqDB->new(-file=>"$FindBin::Bin/test1.fas.aln");
$first_seq = $sdd->get_seq_by_index(0);
#
is ($first_seq->length, 18);
is ($first_seq->get_ungapped_seq, "MSASDRATVDAETTTAT");
is ($first_seq->get_cleaned_seq, "MSASDRATVDAETTTAT");

$sdd->reset_iterator();

 $count = 0;

while ( $sdd->has_next() ) {
	
	my $seqobj = $sdd->next_seq();
	$count++;
	if ($count == 1) {
		is ($seqobj->length, 18);
		is ($seqobj->get_ungapped_seq, "MSASDRATVDAETTTAT");
		is ($seqobj->get_cleaned_seq, "MSASDRATVDAETTTAT");
	}
	
	#print STDERR $count++,"\n";
}

is($count, 3);

my $inmemory_db = SeqToolBox::SeqDB->new();
$inmemory_db->add_seq($first_seq);
$inmemory_db->add_seq($second_seq);
isa_ok($inmemory_db, "SeqToolBox::SeqDB");
is ($inmemory_db->seq_count, 2);
my $f = $inmemory_db->get_seq_by_index (0);
is ($f->get_id, "Ot20g00940");
my $s = $inmemory_db->get_seq_by_index (1);
is ($s->get_id, "gi|15241911|ref|NP_198226.1|");

my @seqs;
while (my $s  = $inmemory_db->next_seq) {
	push @seqs, $s;
}
is (scalar(@seqs), 2);

my @seqs1;
while (my $s  = $inmemory_db->next_seq) {
	push @seqs1, $s;
}
is (scalar(@seqs1), 2);
is ($sdd->get_longest_seq()->get_gi(), "15241911");
