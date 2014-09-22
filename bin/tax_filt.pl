#!/usr/bin/perl -w
# $Id: tax_filt.pl 48 2007-09-14 16:31:36Z malay $

##---------------------------------------------------------------------------##
##  File: tax_filt.pl
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

tax_filt.pl - Write your description here

=head1 SYNOPSIS

tax_filt.pl <option1> <option2> ...

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

use strict;
use Getopt::Long;


##---------------------------------------------------------------------------##
# Option processing
#  e.g.
#   -t: Single letter binary option
#   -t=s: String parameters
#   -t=i: Number paramters
##---------------------------------------------------------------------------##

my @opts = qw( ); # declare your options here
my %options = (); # this hash will have the options

#
# Get the supplied command line options, and set flags
#

_parse_options (\%options, \@opts);


# Print the internal POD documentation if something is missing

if ( $#ARGV == -1 && !$options{'help'} ) {
  print "No options";

  # This is a nifty trick so we don't have to have
  # a duplicate "USAGE()" subroutine.  Instead we
  # just recycle our POD docs.  See PERL POD for more
  # details.
  
  exec "pod2text $0";
  die;
}



exit (0);

######################## S U B R O U T I N E S ############################

sub _parse_options {
	unless ( GetOptions ($_[0], @{$_[1]}) ) {
		exec "pod2text $0";
		exit (0);
	}
}