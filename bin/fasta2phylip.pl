#!/usr/bin/perl -w

use strict;
my $file = shift;
open (FILE, $file) || die "Can't open $file\n";

my @seq;
my @gi;
my %seenid;

my $lastgi;
my $lastseq; 

while (my $line = <FILE>) {
    next if $line =~ /^\#/;
    chomp $line;
    if ($line && $line =~ /^>(\S+)/) {
	my $gi = $1;
	if (exists $seenid{$gi}) {
	    die "Duplicate entry for $gi\n";
	}else {
	    $seenid{$gi} = 1;
	}
	if (defined $lastgi) {
	    $gi[@gi] = $lastgi;
	   
	    $lastgi = $gi;
	    $seq[@seq]= $lastseq;
	    $lastseq = "";
	}else {
	    $lastgi = $gi;
	}
    }elsif ($line) {
	$lastseq .= $line;
    }else {
	
    }
}

$seq[@seq] = $lastseq;
$gi[@gi]= $lastgi;

close FILE;

if (!@seq || !@gi) {
    die "No sequences found in $file\n";
}else {
	
    print ' '.@gi.' '.length ($seq[0])."\n";
    
    
    for (my $i = 0; $i <@gi; $i++) {
		print get_name($gi[$i]);
		print $seq[$i] ,"\n";
    }
}

sub get_name {
	my $name = shift;
	my $length = length($name);
	my $string;
	if ($length == 10 ){
		$string = $name;
	}elsif ($length > 10){
		$string = substr ($name, 0,10);
	}elsif ($length < 10){
		my $gap = 10 - $length;
		$string = $name . " "x$gap;
	}else{
		die "Should not come here\n";
	}
	return $string;
}