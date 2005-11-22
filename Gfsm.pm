package Gfsm;

use 5.008004;
use strict;
use warnings;
use Carp;
use AutoLoader;

our @ISA = qw();

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('Gfsm', $VERSION);

# Preloaded methods go here.
require Gfsm::Alphabet;
require Gfsm::Automaton;

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Gfsm - Perl interface to the libgfsm finite-state library

=head1 SYNOPSIS

  use Gfsm;

  ##... stuff happens

=head1 DESCRIPTION

Not yet written.


=head1 SEE ALSO

perl(1),
gfsmutils(1),
fsm(1).

=head1 AUTHOR

Bryan Jurish E<lt>moocow@ling.uni-potsdam.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Bryan Jurish

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut
