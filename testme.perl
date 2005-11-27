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

sub loadfst {
  $fst = Gfsm::Automaton->new();
  $fst->compile('lkptest.tfst');
  $abet = Gfsm::Alphabet->new();
  $abet->load('test.lab');
}

sub loadmany {
  use vars qw($a);
  my ($NITERS,$fstfile) = @_;
  $NITERS = 1 if (!$NITERS);
  $fstfile = 'test.gfst' if (!$fstfile);
  for ($i=0; $i < $NITERS; $i++) {
    $fst = Gfsm::Automaton->new();
    $fst->load($fstfile);
  }
}
sub loadmany_abet {
  use vars qw($a);
  my ($NITERS,$labfile) = @_;
  $NITERS = 1 if (!$NITERS);
  $labfile = 'test.lab' if (!$labfile);
  for ($i=0; $i < $NITERS; $i++) {
    undef $abet;
    $abet = Gfsm::Alphabet->new();
    $abet->load($labfile);
  }
}

sub lkptest {
  use vars qw($paths);
  loadfst();
  $result = $fst->lookup([2,2,3]);
  $paths  = $result->paths();
}

sub lkpmany {
  use vars qw($paths);
  my $NITERS = shift;
  $NITERS = 1 if (!$NITERS);
  loadfst();
  for ($i=0; $i < $NITERS; $i++) {
    $result = $fst->lookup([2,2,3]);
    #$paths  = $result->paths();
  }
}

sub newmany {
  my $NITERS = shift;
  $NITERS = 1 if (!$NITERS);
  for ($i=0; $i < $NITERS; $i++) {
    $fst = Gfsm::Automaton->new();
  }
}


##-- dummy
foreach $i (0..10) {
  print "--dummy($i)--\n";
}

