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

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Gfsm::Alphabet - object-oriented interface to libgfsm string alphabets

=head1 SYNOPSIS

  use Gfsm;

  $abet = Gfsm::Alphabet->new();

  ##... stuff happens

=head1 DESCRIPTION

Not yet written.

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
