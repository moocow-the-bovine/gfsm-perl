package Gfsm::Alphabet;

use IO::File;
use Carp;

##======================================================================
## Constants
##======================================================================
our $NULL = bless \(my $x=0), 'Gfsm::Alphabet';

##======================================================================
## I/O: Wrappers
##======================================================================

## $bool = $abet->load($filename_or_fh);
sub load {
  my ($abet,$file) = @_;
  my $fh = ref($file) ? $file : IO::File->new("<$file");
  if (!$fh) {
    carp(ref($abet),"::load(): could not open file '$file': $!");
    return 0;
  }
  my $rc = $abet->_load($fh);
  carp(ref($abet),"::load(): error loading file '$file': $Gfsm::Error\n") if (!$rc);
  $fh->close() if (!ref($file));
  return $rc;
}

## $bool = $abet->save($filename_or_fh);
sub save {
  my ($abet,$file) = @_;
  my $fh = ref($file) ? $file : IO::File->new(">$file");
  if (!$fh) {
    carp(ref($abet),"::save(): could not open file '$file': $!");
    return 0;
  }
  my $rc = $abet->_save($fh);
  carp(ref($abet),"::save(): error saving file '$file': $Gfsm::Error\n") if (!$rc);
  $fh->close() if (!ref($file));
  return $rc;
}

1;

__END__

=pod

=head1 NAME

Gfsm::Alphabet - object-oriented interface to libgfsm string alphabets.

=head1 SYNOPSIS

 use Gfsm;

 ##------------------------------------------------------------
 ## Constructors, etc.
 $abet = Gfsm::Alphabet->new(); # construct a new alphabet
 $abet->clear();                # empty the alphabet

 ##--------------------------------------------------------------
 ## Alphabet properties
 $lab = $abet->lab_min();       # get first allocated LabelId
 $lab = $abet->lab_max();       # get last allocated LabelId
 $n   = $abet->size();          # get number of defined labels

 ##--------------------------------------------------------------
 ## Lookup & Manipulation
 $lab = $abet->insert($key);       # insert a key string
 $lab = $abet->insert($key,$lab);  # insert a key string, requesting label $lab

 $lab = $abet->get_label($key);    # get or insert label for $key
 $lab = $abet->find_label($key);   # get label for $key, else Gfsm::noLabel

 $key = $abet->find_key($lab);     # get key for label, else undef

 $abet->remove_key($key);          # remove a key, if defined
 $abet->remove_label($lab);        # remove a label, if defined

 $abet->merge($abet2);             # add $abet2 keys to $abet1
 $labs = $abet->labels();          # get array-ref of all labels in $abet

 ##--------------------------------------------------------------
 ## I/O
 $abet->load($filename_or_handle); # load AT&T-style .lab file
 $abet->save($filename_or_handle); # save AT&T-style .lab file

 ##--------------------------------------------------------------
 ## String utilities
 $labs = $abet->string_to_labels($str,$emit_warnings=1);               # lab-ify by character
 $str  = $abet->labels_to_string($labs,$emit_warnings=1,$att_style=0); # stringify

=head1 DESCRIPTION

Gfsm::Alphabet provides an object-oriented interface to string symbol
alphabets as used by the libgfsm library.

=cut

########################################################################
## FOOTER
########################################################################

=pod

=head1 BUGS AND LIMITATIONS

Probably many.

=head1 SEE ALSO

Gfsm(3perl),
gfsmutils(1).


=head1 AUTHOR

Bryan Jurish E<lt>moocow@ling.uni-potsdam.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Bryan Jurish

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
