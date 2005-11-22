#!/usr/bin/perl -wd

use lib qw(./blib/lib ./blib/arch);
use Gfsm;

sub loadlabs {
  $abet = Gfsm::Alphabet->new();
  $abet->load('test.lab');
}

sub loadfsm {
  $fsm = Gfsm::Automaton->new();
  $fsm->load('test.gfst');
}

##-- dummy
foreach $i (0..10) {
  print "--dummy($i)--\n";
}

