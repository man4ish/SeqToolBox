# Perl module for SeqToolBox::NGS::Snpeff.pm
# Author: Malay < curiouser@ccmp.ap.nic.in >
# Copyright Malay
# You may distribute this module under the same terms as perl itself

# POD documentation - main docs before the code

=head1 NAME

SeqToolBox::NGS::Snpeff.pm - DESCRIPTION of Object

=head1 SYNOPSIS

Give standard usage here

=head1 DESCRIPTION

Describe the object here

=head1 CONTACT

Malay <mbasu@mail.nih.gov>


# Let the code begin...


package SeqToolBox::NGS::Snpeff.pm;
@ISA = qw();
@EXPORT_OK = qw();

use strict;


=head1 CONSTRUCTOR

=cut

sub new {
   my $class = shift;

   my $self = {};
   bless $self, ref($class) || $class;
   $self->_init(@_);
   return $self;
}

# _init is where the heavy stuff will happen when new is called

sub _init {
  my($self,@args) = @_;

  my $make = $self->SUPER::_initialize;

  _parse_eff ($args[0]);
# set stuff in self from @args
 return $make; # success - we hope!
}


=head2 _parse_eff()

 Usage:
 Function:
 Example:
 Returns: 
 Arguments

=cut

sub _parse_eff{
  my ($self,@args) = @_;

  
}


=head1 APPENDIX



=cut

1;
