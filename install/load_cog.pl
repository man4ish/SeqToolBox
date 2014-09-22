#!/usr/bin/env perl
#$Id: load_cog.pl 49 2007-09-14 16:39:14Z malay $

BEGIN{$^W = 1}
use strict;
use DBI;

my $whog = shift;
my $names = 'cog_member.db';
my $def = 'cog_class.db';
my $dbh1 = DBI->connect( "dbi:SQLite:dbname=$names", "", "",
							{ RaiseError => 1, AutoCommit => 0 } );
my $dbh2 = DBI->connect( "dbi:SQLite:dbname=$def", "", "",
							{ RaiseError => 1, AutoCommit => 0 } );
$dbh1->do ('create table cog_member ("id","species","cog")');
$dbh2->do ('create table cog_class ("cog","func","des")');

my $sql = 'insert into cog_member ("id","species","cog") values (?,?,?)';
my $sth1 = $dbh1->prepare($sql);
$sql = 'insert into cog_class("cog","func","des") values (?,?,?)';
my $sth2 = $dbh2->prepare($sql);

open (my $infile, "$whog") || die "Can't open $whog:$!\n";

my $count =0;
my $lastcog;
my $lastsp;
while (my $line = <$infile>){
		$count++;
		if ($count > 10000) {
			$dbh1->commit;
			$dbh2->commit;
		}
		chomp $line;
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;
		
		if (!$line){
			next;
		}
		elsif ($line =~ /^_*$/) {
			print STDERR "$lastcog parsed\n";
			next;
			
		}
		elsif ($line =~ /^\[(\S+)\]\s+(\S+)\s+(.*)/ ) {
			my $class = $1;
			my $cog = $2;
			my $desc = $3;
			if (!$class || !$cog || !$desc){
				die "Something wrong in parsing $line\n";
			}else{
				$sth2->execute($cog, $class, $desc);
				$lastcog = $cog;
			}
		}elsif ($line =~ /(\S+)\:\s+(.*)/) {
			$lastsp = $1;
			my @acc = split (/\s+/, $2);
			unless ($lastsp || @acc || $lastcog) {
				die "Something wrong in parsing $line\n";
				
			}
			foreach my $i (@acc) {
				$sth1->execute ($i, $lastsp, $lastcog);
			}
		}else {
			my @acc = split (/\s+/, $line);
			unless ($lastsp || @acc || $lastcog) {
				die "Something wrong in parsing $line\n";
				
			}
			foreach my $i (@acc) {
				$sth1->execute ($i, $lastsp, $lastcog);
			}
		}
		
}

$dbh1->commit();
$dbh2->commit();
$sth1->finish();
$sth2->finish();
$sth1 = undef;
$sth2 = undef;

$dbh1->do ('create index index1 on cog_member ("id")');
$dbh2->do ('create index index1 on cog_class ("cog")');

$dbh1->commit();
$dbh2->commit();

$dbh1->disconnect;
$dbh2->disconnect;

close($infile);
							
							