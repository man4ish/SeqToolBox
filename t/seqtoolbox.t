#!/usr/bin/perl -w
use FindBin;
use lib "$FindBin::Bin/../lib";
use strict;
use Test::More ("no_plan");

require_ok ("SeqToolBox");
use SeqToolBox;
my $tool = SeqToolBox->new();
my $db_dir = $ENV{SEQTOOLBOXDB} || "/tmp";
is($tool->get_dbdir, $db_dir);


