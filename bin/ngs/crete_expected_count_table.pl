#!/usr/bin/perl -w
use strict;
use File::Basename;
use File::Spec;

my $dir = shift;
opendir(DIR, $dir) || die "Can't open $dir\n";
my %data;
my %files;
while (my $file = readdir(DIR)) {
    next unless $file =~ /\.genes\.results$/;
    my $filename = File::Spec->catfile($dir, $file);
    my $basename = basename($file, ".genes.results");
    $files{$basename} = 1;
    open (FILE, $filename) || die "Can't open $filename";
    while (my $line = <FILE>) {
        next if $. == 1;
        my @F = split ("\t", $line);
        if (scalar(@F) != 7 ) {
            die "Error reading $file. Not a RSEM output. It should have 7 columns\n";
        }
        $data{$F[0]}->{$basename} = $F[4];
    }
    close (FILE);
}

my @files = sort ( keys %files);
print ( join ("\t","gene_id", @files), "\n");
for my $gene (sort {"\L$a" cmp "\L$b"} ( keys %data)) {
    my @line = ();
    push @line, $gene;
    for my $f (@files) {
        if (exists($data{$gene}->{$f}) ) {
            push @line, $data{$gene}->{$f};
        }else {
            push @line, 0;
        }
    }
    print join("\t", "@line"), "\n";
}