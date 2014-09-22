#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);
use strict;

require_ok("SeqToolBox::Dollo");

my $obj = SeqToolBox::Dollo->new (-file => 't/NCBI_GNO_132294.dollo.out');
isa_ok($obj, "SeqToolBox::Dollo");
my $tree = $obj->get_tree();
#my $out = Bio::TreeIO->new(-format => 'newick', -fh => \*STDOUT);
#$out->write_tree($tree);
is ($tree->get_root_node()->id(),"1");
my @node_data = $obj->get_node_data_by_node($tree->get_root_node);
is_deeply (\@node_data, ["."]);
@node_data = $obj->get_node_data_by_id("GI_9099171");
is_deeply(\@node_data,["1"]);
is ($obj->get_node_gain_by_id("GI_9099171"),"1");
is ($obj->get_node_loss_by_id("GI_9099171"),"0");
