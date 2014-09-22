use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

require_ok("SeqToolBox::DB::Cdhit");
my $sdb = SeqToolBox::DB::Cdhit->new(-dbfile=>'t/cdhit_test_db.sqlite');
isa_ok($sdb, "SeqToolBox::DB::Cdhit");
my @result = $sdb->get_organisms();

is_deeply (\@result, ['A. gambei']);