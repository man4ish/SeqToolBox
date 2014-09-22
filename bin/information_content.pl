#!/usr/bin/perl -w
use strict;

my $file = shift;
my $start = shift;
my $end = shift;

open (FILE, $file) || die "Can't open $file\n";

my $freq;
my $total;

while (my $line = <FILE>) {
	chomp $line;
	my @char = split (//, $line);
	for (my $i = 0; $i < @char; $i++) {
		my $c = uc($char[$i]);
		$freq->{$i}->{$c}++;
		$total->{$i}++;
	}
}
close (FILE);

my @infs;

for (my $i = $start - 1; $i < $end; $i++) {
	my $inf;
	foreach my $j(keys %{$freq->{$i}}) {
		my $f = $freq->{$i}->{$j} / $total->{$i};
		$inf += $f * log2($f);		
	}
	print $i+1 ,"\t", sprintf ("%.3f", 2+ $inf),"\n";		
	push @infs, sprintf ("%.3f", 2+$inf);
}

my $sum;
foreach my $i (@infs){
	$sum += $i;
}

print "Sum\t$sum\n";
sub log2 {
	my $value = shift;
	return log($value) / log(2);
}