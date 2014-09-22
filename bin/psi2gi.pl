#!/usr/bin/perl -w
# $Id:psi2gi.pl 22 2007-08-03 17:28:24Z malay $

##---------------------------------------------------------------------------##
##  File: psi2gi.pl
##       
##  Author:
##        Malay <malay@bioinformatics.org>
##
##  Description:
##     
#******************************************************************************
#* Copyright (C) 2007 Malay K Basu <malay@bioinformatics.org> 
#* This work is distributed under the license of Perl iteself.
###############################################################################

=head1 NAME

psi2gi.pl - Extracts gi list from psi-blast output

=head1 SYNOPSIS

psi2gi.pl filename

=head1 DESCRIPTION

The options are:

=over 4

=item <first option>

=item <second option>

=back


=head1 SEE ALSO

=head1 COPYRIGHT

Copyright (c) 2007 Malay K Basu <malay@bioinformatcs.org>

=head1 AUTHORS

Malay K Basu <malay@bioinformatics.org>

=cut


##---------------------------------------------------------------------------##
## Module dependencies
##---------------------------------------------------------------------------##
use FindBin;
use lib "$FindBin::Bin/../lib";
use SeqToolBox::BLASTParser;
use strict;
use Getopt::Long;


##---------------------------------------------------------------------------##
# Option processing
#  e.g.
#   -t: Single letter binary option
#   -t=s: String parameters
#   -t=i: Number paramters
##---------------------------------------------------------------------------##

my @opts = qw(help); # declare your options here
my %options = (); # this hash will have the options

#
# Get the supplied command line options, and set flags
#

_parse_options (\%options, \@opts);


# Print the internal POD documentation if something is missing

if ( ($#ARGV == -1 && !$options{'help'}) || $options{'help'} ) {
  #print "No options";

  # This is a nifty trick so we don't have to have
  # a duplicate "USAGE()" subroutine.  Instead we
  # just recycle our POD docs.  See PERL POD for more
  # details.
  
  exec "pod2text $0";
  die;
}



my $filename = shift;
my $parser;

if ($filename eq '-') {
	$parser = SeqToolBox::BLASTParser->new(-fh=>\*STDIN,-format=>'pgp');		
}else {
	$parser = SeqToolBox::BLASTParser->new(-file=>$filename,-format=>'pgp');
}

my @gi_list = $parser->get_gi_list();

foreach my $i (@gi_list) {
	print $i,"\n";
}




exit (0);





######################## S U B R O U T I N E S ############################

sub _parse_options {
	unless ( GetOptions ($_[0], @{$_[1]} ) ){
		exec "pod2text $0";
		exit (0);
	}
}