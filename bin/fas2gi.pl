#!/usr/bin/perl -w
# $Id: fas2gi.pl 82 2007-11-21 21:57:23Z malay $

##---------------------------------------------------------------------------##
##  File: fas2gi.pl
##
##  Author:
##        Malay <malay@bioinformatics.org>
##
#******************************************************************************
#* Copyright (C) 2007 Malay K Basu <malay@bioinformatics.org>
#* This work is distributed under the license of Perl iteself.
###############################################################################

=head1 NAME

fas2gi.pl - Perl script to create a list of Gi's given a fasta file.

=head1 SYNOPSIS

fas2gi.pl [options] <file>

Options:

	--all	Prints the Id value
	--help  Prints a short usage message
	--? 	same as above
	--man   Print the whole man page

=head1 OPTIONS

=over 8

=item <--all>

Print the ID (first word after ">") if the script doesn't find any GI in the sequence definition.

=item <--help> 

Prints a short help message

=item <-?>

Same as above

=item <--man>

Prints the manual page.

=back

=head1 DESCRIPTION

The script operates on a FASTA file (or FASTA file piped into the script) and prints GI for each sequence in the file.
Instead of a Filename a sequeces can be given piped in the script. The script then print the GIs. If the option --all is given
then if the script doesn't find a GI in the sequence definition line, it will print the sequence ID (first word after the ">"), otherwise
the sequence will be scipped.

=head1 COPYRIGHT

Copyright (c) 2007 Malay K Basu <malay@bioinformatcs.org>

=head1 AUTHORS

Malay K Basu <malay@bioinformatics.org>

=cut

##---------------------------------------------------------------------------##
## Module dependencies
##---------------------------------------------------------------------------##

use strict;
use Getopt::Long;
use Pod::Usage;
use FindBin;


#use lib "$Findbin::Bin/../lib";
#use IO::File;
#use SeqToolBox::SeqDB;

my $all = '';
my $help = '';
my $man = '';
my $re = '';
GetOptions( 'all' => \$all,"help|?"=>\$help, "man"=>\$man, "re=s" =>\$re );
if ($help){
	pod2usage (-exitval=> 0,-verbose=> 0);
	
}


if ($man){
	pod2usage (-exitval=>0, -verbose=>2);
}

my $file = shift;
my $fh;

if ( !$file ) {
	$fh = \*STDIN;
}
else {
	open my $in, "$file" || die "Can't open $file: $!\n";
	$fh = $in;
}

while ( my $line = <$fh> ) {
	chomp $line;
	if ($re) {
		if ($line =~ /$re/) {
			print $1,"\n";
		}
		next;
	}
	
	if ( $line =~ /^\>(\S+)/ ) {
		my $id = $1;
		if ( $id =~ /gi\|(\d+)\|/ ) {
			print $1, "\n";

		}
		elsif ( $id =~ /gi\|(\d+)/ ) {
			print $1, "\n";
		}
		elsif ($all) {
			print $id, "\n";
		}
		else {

		}
	}
}

close $fh;
exit (0);