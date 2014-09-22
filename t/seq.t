use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More "no_plan";
require_ok("SeqToolBox::Seq");
my $seq = SeqToolBox::Seq->new(
			   -id  => "myseq",
			   -des => 'some des',
			   -seq => "HRRVKLFEKDPTRQVATYVEAVKTVDPMKAAGKPHTLWVAFAKMYEKHNRLDSAE"
);
is( $seq->get_id(), "myseq" );
is( $seq->get_seq,  "HRRVKLFEKDPTRQVATYVEAVKTVDPMKAAGKPHTLWVAFAKMYEKHNRLDSAE" );
is ($seq->get_subseq(-start=>1,-end=>3), "HRR");
is( $seq->get_desc, 'some des' );
$seq->set_desc("new des");
is( $seq->get_desc, "new des" );
$seq->set_id("new id");
is( $seq->get_id, "new id" );
$seq->set_seq("AGTC");
is( $seq->get_seq, "AGTC" );
is ($seq->revcom, "GACT");

my %pos = (2 => "|", 3=>"|");
my $marked_seq = $seq->mark_position(\%pos);
#my $marked_seq1 = $seq->mark_position([2,3],"|");
is ($marked_seq->get_seq(), "AG|T|C");
