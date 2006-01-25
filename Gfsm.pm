package Gfsm;

use 5.008004;
use strict;
use warnings;
use Carp;
use AutoLoader;
use Exporter;

our @ISA = qw(Exporter);

our $VERSION = '0.0202';

require XSLoader;
XSLoader::load('Gfsm', $VERSION);

# Preloaded methods go here.
require Gfsm::Alphabet;
require Gfsm::Automaton;

# Autoload methods go after =cut, and are processed by the autosplit program.

##======================================================================
## Exports
##======================================================================
our @EXPORT = qw();
our %EXPORT_TAGS = qw();

##======================================================================
## Constants
##======================================================================

##------------------------------------------------------------
## Constants: arc labels
our $epsilon = epsilon();
our $noLabel = noLabel();
$EXPORT_TAGS{labels} = [qw(epsilon $epsilon noLabel $noLabel)];

##------------------------------------------------------------
## Constants: State IDs
our $noState = noState();
$EXPORT_TAGS{states} = [qw(noState $noState)];

##--------------------------------------------------------------
## Constants: Semiring types
our $SRTUnknown  = SRTUnknown();
our $SRTBoolean  = SRTBoolean();
our $SRTLog      = SRTLog();
our $SRTReal     = SRTReal();
our $SRTTrivial  = SRTTrivial();
our $SRTTropical = SRTTropical();
our $SRTPLog     = SRTPLog();
our $SRTUser     = SRTUser();
$EXPORT_TAGS{srtypes} = [
			 qw($SRTUnknown   SRTUnknown),
			 qw($SRTBoolean   SRTBoolean),
			 qw($SRTLog       SRTLog),
			 qw($SRTReal      SRTReal),
			 qw($SRTTrivial   SRTTrivial),
			 qw($SRTTropical  SRTTropical),
			 qw($SRTPLog      SRTPLog),
			 qw($SRTUser      SRTUser),
			];

##--------------------------------------------------------------
## Constants: Automaton arc-sort modes
our $ASMNone   = ASMNone();
our $ASMLower  = ASMLower();
our $ASMUpper  = ASMUpper();
our $ASMWeight = ASMWeight();

$EXPORT_TAGS{sortmodes} = [
			   qw($ASMNone   ASMNone),
			   qw($ASMLower  ASMLower),
			   qw($ASMUpper  ASMUpper),
			   qw($ASMWeight ASMWeight),
			  ];

##--------------------------------------------------------------
## Constants: Label sides
our $LSBoth  = LSBoth();
our $LSLower = LSLower();
our $LSUpper = LSUpper();

$EXPORT_TAGS{labelsides} = [
			    qw($LSBoth  LSBoth),
			    qw($LSLower LSLower),
			    qw($LSUpper LSUpper),
			   ];

##======================================================================
## Exports: finish
##======================================================================
our @EXPORT_OK = map { @$_ } values(%EXPORT_TAGS);
$EXPORT_TAGS{constants} = \@EXPORT_OK;


1;

__END__

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Gfsm - Perl interface to the libgfsm finite-state library

=head1 SYNOPSIS

  use Gfsm;

  ##... stuff happens

=head1 DESCRIPTION

The Gfsm module provides an object-oriented interface to the libgfsm library
for finite-state machine operations.

=head1 SEE ALSO

Gfsm::constants(3perl),
Gfsm::Alphabet(3perl),
Gfsm::Automaton(3perl),
Gfsm::Semiring(3perl),
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
