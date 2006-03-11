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

##--------------------------------------------------------------
## Converters: hash

## \%sym2id_hash = $abet->toHash()
## \%sym2id_hash = $abet->toHash(\%hash)
#*asHash = \&toHash;
sub toHash {
  my ($abet,$h) = @_;
  $h = {} if (!defined($h));
  %$h = map { $abet->find_key($_)=>$_ } @{$abet->labels()};
  return $h;
}

## $abet = $abet->fromHash(\%sym2id_hash)
##  + does NOT implicitly clear alphabet
sub fromHash {
  my ($abet,$h) = @_;
  my ($key,$lab);
  while (($key,$lab)=each(%$h)) {
    $abet->get_label($key,(defined($lab) ? $lab : $Gfsm::noLabel));
  }
  return $abet;
}

##--------------------------------------------------------------
## Converters: array

## \@id2sym_array = $abet->toArray()
## \@id2sym_array = $abet->toArray(\@id2sym_array)
#*asArray = \&toArray;
sub toArray {
  my ($abet,$ary) = @_;
  $ary = [] if (!defined($ary));
  $ary->[$_] = $abet->find_key($_) foreach (@{$abet->labels()});
  return $ary;
}

## $abet = $abet->fromArray(\@id2sym_array)
##  + does NOT implicitly clear alphabet
sub fromArray {
  my ($abet,$ary) = @_;
  my ($i,$key);
  foreach $i (0..$#$ary) {
    next if (!defined($key=$ary->[$i]));
    $abet->get_label($key,$i);
  }
  return $abet;
}

##--------------------------------------------------------------
## I/O: Wrappers: Binary: Storable

## ($serialized, $ref1, ...) = $fsm->STORABLE_freeze($cloning)
sub STORABLE_freeze {
  my ($abet,$cloning) = @_;
  #return $abet->clone if ($cloning); ##-- weirdness
  return ('',$abet->toHash);
}

## $abet = STORABLE_thaw($abet, $cloning, $serialized, $ref1,...)
sub STORABLE_thaw {
  my ($abet,$cloning) = @_[0,1];

  ##-- STRANGENESS (race condition on perl program exit)
  ##   + Storable already bless()d a reference to undef for us: this is BAD
  ##   + hack: set its value to 0 (NULL) so that DESTROY() ignores it
  $$abet = 0;

  ##-- we must make a *real* new object: $new
  my $new = ref($abet)->new();
  $$abet  = $$new;
  $$new   = 0;                ##-- ... but not destroy it...
  undef($new);

  ##-- now do the actual deed
  $abet->fromHash($_[3])
    or croak(ref($abet)."::STORABLE_thaw(): error loading from hashref.\n");
}

##======================================================================
## Methods: Wrappers
##======================================================================

*insert = \&get_label;

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
 #$labs = $abet->string_to_labels($str,$emit_warnings=1);               # BUGGY: lab-ify by character
 #$str  = $abet->labels_to_string($labs,$emit_warnings=1,$att_style=0); # BUGGY: stringify

 ##--------------------------------------------------------------
 ## Conversion
 $abet      = $abet->fromHash(\%string2id);  # add mappings from \%string2id_hash
 $string2id = $abet->toHash();               # export mappings to hash-ref
 $string2id = $abet->asHash();               # read-only access to underlying index

 $abet      = $abet->fromArray(\@id2string); # add mappings from \@id2string
 $id2string = $abet->toArray();              # export mappings to array-ref
 $id2string = $abet->asArray();              # read-only access to underlying index



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
