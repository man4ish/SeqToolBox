use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);
use strict;
use Data::Dumper;


require_ok("SeqToolBox::Tools::Set");

my $set = SeqToolBox::Tools::Set->new();
isa_ok ($set,"SeqToolBox::Tools::Set");

my @a = (1,2,3);
my @b = (4,5,6);
my @c = (7,8, 9);
$set->add_set(\@a, \@b);
$set->add_set(\@c);

my @test = $set->get_set(0);
#print STDERR "@test\n";
is_deeply(\@test,\@a);
@test = $set->get_set(1);
is_deeply(\@test, \@b);

@test = $set->get_set(2);
is_deeply (\@test, \@c);

my @test_union = (@a, @b, @c);

@test = $set->get_all_union();
is_deeply (\@test_union, \@test);

my $set1 = SeqToolBox::Tools::Set->new();
@a = (1,2,3,4,5);
@b = (6,7,3,5);
@c = (3,5,8,9);

$set1->add_set(\@a,\@b,\@c);
my @common = (3,5);

@test = $set1->get_all_intersection();
is_deeply(\@common, \@test);

@test = $set1->get_intersection (0,1);
is_deeply (\@common, \@test);

@test = $set1->get_intersection(1,2);
is_deeply (\@common, \@test);

my $uniques = $set1->get_uniques();
my @unique1 = (1,2,4);
my @unique2 = (6,7);
my @unique3 = (8,9);
is_deeply (\@unique1, $uniques->[0]);
is_deeply (\@unique2, $uniques->[1]);
is_deeply (\@unique3, $uniques->[2]);





#print STDERR Dumper($set);