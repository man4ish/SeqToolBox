use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);
use IO::File;
use Data::Dumper;

require_ok("SeqToolBox::SeqDB");
my $fh = IO::File->new("$FindBin::Bin/test.fas.aln","r");
my $sdb = SeqToolBox::SeqDB->new(-fh=>$fh);
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
my $fh1 = IO::File->new("$FindBin::Bin/test1.fas.aln","r");
my $sdd = SeqToolBox::SeqDB->new(-fh=>$fh1);
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
my $index_file = File::Spec->catfile($FindBin::Bin,"test_seq_index.idx");
unlink ($index_file) if (-s $index_file);
$sdd->create_index($index_file);
my $i_seq = $sdd->get_seq_by_id("Ot20g00940");
is ($i_seq->length,18, "Matches length");
is ($i_seq->get_ungapped_seq, "MSASDRATVDAETTTAT");
		is ($i_seq->get_cleaned_seq, "MSASDRATVDAETTTAT");
		$i_seq = $sdd->get_seq_by_id('AK101483|Os07g0644300');
is ($i_seq->get_id,'AK101483|Os07g0644300');
$i_seq = $sdd->get_seq_by_id('gi|15241911|ref|NP_198226.1|');
is ($i_seq->get_id,'gi|15241911|ref|NP_198226.1|');

$sdd->create_index("$FindBin::Bin/test1.fas.aln.idx");

my $sde = SeqToolBox::SeqDB->new(-file=>"$FindBin::Bin/test1.fas.aln",-index=>"$FindBin::Bin/test1.fas.aln.idx");
 $i_seq = $sde->get_seq_by_id("Ot20g00940");
is ($i_seq->length,18);
is ($i_seq->get_ungapped_seq, "MSASDRATVDAETTTAT");
		is ($i_seq->get_cleaned_seq, "MSASDRATVDAETTTAT");
		$i_seq = $sde->get_seq_by_id('AK101483|Os07g0644300');
is ($i_seq->get_id,'AK101483|Os07g0644300');
$i_seq = $sde->get_seq_by_id('gi|15241911|ref|NP_198226.1|');
is ($i_seq->get_id,'gi|15241911|ref|NP_198226.1|');

my $sdf = SeqToolBox::SeqDB->new(-file=>"$FindBin::Bin/test1.fas.aln");
$i_seq = $sdf->get_seq_by_id("Ot20g00940");
is ($i_seq->length,18);
is ($i_seq->get_ungapped_seq, "MSASDRATVDAETTTAT");
		is ($i_seq->get_cleaned_seq, "MSASDRATVDAETTTAT");
		$i_seq = $sdf->get_seq_by_id('AK101483|Os07g0644300');
is ($i_seq->get_id,'AK101483|Os07g0644300');
$i_seq = $sdf->get_seq_by_id('gi|15241911|ref|NP_198226.1|');
is ($i_seq->get_id,'gi|15241911|ref|NP_198226.1|');

#system ("rm $FindBin::Bin/test1.fas.aln.idx.dir $FindBin::Bin/test1.fas.aln.idx.pag") == 0 || die "Can't remove index files\n";
my $sdg = SeqToolBox::SeqDB->new(-file=>"$FindBin::Bin/test1.fas.aln");
$i_seq = $sdg->get_seq_by_id("Ot20g00940");
is ($i_seq->length,18);
is ($i_seq->get_ungapped_seq, "MSASDRATVDAETTTAT");
		is ($i_seq->get_cleaned_seq, "MSASDRATVDAETTTAT");
		$i_seq = $sdg->get_seq_by_id('AK101483|Os07g0644300');
is ($i_seq->get_id,'AK101483|Os07g0644300');
$i_seq = $sdg->get_seq_by_id('gi|15241911|ref|NP_198226.1|');
is ($i_seq->get_id,'gi|15241911|ref|NP_198226.1|');

unlink File::Spec->catfile($FindBin::Bin,'test1.fas.aln.idx') || die ("Can't delete tmp file\n");
unlink $index_file;
#print STDERR (Dumper($i_seq));