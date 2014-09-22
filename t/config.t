use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);
use strict;

require_ok("SeqToolBox::Config");

my $config = SeqToolBox::Config->new();
isa_ok ($config,"SeqToolBox::Config");
$config->get_file_stamp("a","b","c");