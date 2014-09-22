use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More "no_plan";
use strict;
#Test 1
require_ok("SeqToolBox::Intron");

my $intron = SeqToolBox::Intron->new(
	"ftstring" => "37393..38447,38940..39050",
	strand => '-');
#Test2
is_deeply([1,111,604,1658],$intron->{coords});

#Test3
my @result = $intron->get_normalized_exons();
is_deeply([1,111,604,1658],\@result);

#Test4
@result = $intron->get_normalized_exon_end();
is_deeply([111,1658],\@result);

#Test5
@result = $intron->get_normalized_exon_start();
is_deeply([1,604],\@result);

#Test6
@result = $intron->get_intron_positions();
is_deeply([112],\@result);

#Test7
@result = $intron->get_intron_pos_subtracting_intron();
is_deeply([111],\@result);
#print "@result\n";

#Test8
@result = $intron->get_intron_phases();
is_deeply([0],\@result);
#print "@result\n";

#Test9
@result = $intron->get_intron_lengths();
is_deeply([492],\@result);

$intron = SeqToolBox::Intron->new(
	"ftstring" => "7393..8447,8940..9050,9129..9237");
	
#Test10
is_deeply([7393,8447,8940,9050,9129,9237],$intron->{coords});

#Test11
@result = $intron->get_normalized_exons();
is_deeply([1,1055,1548, 1658, 1737, 1845],\@result);

#Test12
@result = $intron->get_normalized_exon_end();
is_deeply([1055,1658,1845],\@result);

#Test13
@result = $intron->get_normalized_exon_start();
is_deeply([1,1548,1737],\@result);

#Test14
@result = $intron->get_intron_positions();
is_deeply([1056,1659],\@result);

#Test15
@result = $intron->get_intron_pos_subtracting_intron();
is_deeply([1055,1166],\@result);

#Test8
@result = $intron->get_intron_phases();
is_deeply([2,2],\@result);

$intron = SeqToolBox::Intron->new(
	"ftstring" => "1..3,6..9");
@result = $intron->get_intron_phases();
is_deeply([0],\@result);

$intron = SeqToolBox::Intron->new(
	"ftstring" => "1..3,6..8,12..15");
@result = $intron->get_intron_phases();
is_deeply([0,0],\@result);

@result = $intron->get_intron_pos_subtracting_intron();
is_deeply([3,6],\@result);

my $cl = $intron->get_cds_length();
is(10, $cl);
$intron = SeqToolBox::Intron->new(
	"ftstring" => "6..8,12..15,18..20");
@result = $intron->get_intron_pos_subtracting_intron();
is_deeply([3,7],\@result);
@result = $intron->get_intron_phases();
is_deeply([0,1],\@result);

$intron = SeqToolBox::Intron->new(ftstring => "6..8,12..15,18..21", strand=>'-');
@result = $intron->get_intron_phases();
is_deeply([1,2],\@result);

$intron = SeqToolBox::Intron->new(ftstring=>"3276110..3276181,3276264..3276361,3276439..3276568,3276659..3276711,3276854..3276909,3277003..3277163,3277334..3277588,3277767..3277837,3278047..3278114,3278192..3278466", strand => '-');
@result = $intron->get_intron_phases();
is_deeply([2,1,0,0,2,1,0,1,0],\@result);

