#!/usr/bin/env perl
# $Id$

##---------------------------------------------------------------------------##
##  File: index_fasta.pl
##       
##  Author:
##        Malay <malay@bioinformatics.org>
##
##  Description:
##     
#******************************************************************************
#* Copyright (C) 2012 Malay K Basu <malay@bioinformatics.org> 
#* This work is distributed under the license of Perl iteself.
###############################################################################

=head1 NAME

index_fasta.pl - One line description.

=head1 SYNOPSIS

index_fasta.pl [options] -o <option>


=head1 DESCRIPTION

Write a description of your prgram. 


=head1 ARGUMENTS 

=over 4

=item B<--option|-o>

First option.



=back

=head1 OPTIONS

Something here.


=head1 SEE ALSO

=head1 COPYRIGHT

Copyright (c) 2012 Malay K Basu <malay@bioinformatics.org>

=head1 AUTHORS

Malay K Basu <malay@bioinformatics.org>

=cut



##---------------------------------------------------------------------------##
## Module dependencies
##---------------------------------------------------------------------------##

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use FindBin;
use lib $FindBin::Bin.'/../lib';
use SeqToolBox::SeqDB;

my $file = shift;
my $seqdb = SeqToolBox::SeqDB->new (-file => $file);
$seqdb->create_index();

