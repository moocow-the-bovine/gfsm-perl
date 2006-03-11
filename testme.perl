#!/usr/bin/perl -wd

use lib qw(./blib/lib ./blib/arch);
use Gfsm;
use Storable qw(freeze thaw);

sub perlhash {
  my $key = shift;
  my $hash = 0;
  my ($i);
  for ($i=0; $i < length($key); $i++) {
    $hash = ($hash * 33) + ord(substr($key,$i,1));
  }
  $hash = $hash + ($hash >> 5);
  return $hash;
}


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

sub scalarlabs {
  $slabs = Gfsm::Alphabet->new;
  our @id2lab = ({},{a=>1});
  $slabs->fromArray(\@id2lab);
  our $slabsf = freeze($slabs);
  our $slabst = thaw($slabsf);
}


##--------------------------------------------------------------
## I/O: Wrappers: Binary: Storable
package Gfsm::Automaton;

## ($serialized, $ref1, ...) = $fsm->STORABLE_freeze($cloning)
sub STORABLE_freeze_new {
  my ($fsm,$cloning) = @_;
  #return $fsm->clone if ($cloning); ##-- weirdness

  my $buf = '';
  $fsm->save_string($buf)
    or croak(ref($fsm)."::STORABLE_freeze(): error saving to string: $Gfsm::Error\n");

  return ($buf);
}

## $fsm = STORABLE_thaw($fsm, $cloning, $serialized, $ref1,...)
sub STORABLE_thaw_new {
  my ($fsm,$cloning) = @_[0,1];

  ##-- STRANGENESS (race condition on perl program exit)
  ##   + Storable already bless()d a reference to undef for us: this is BAD
  ##   + hack: set its value to 0 (NULL) so that DESTROY() ignores it
  $$fsm = 0;

  ##-- check for dclone() operations: weirdness here
  #if ($cloning) {
  #  $$fsm = ${$_[2]};
  #  ${$_[2]} = 0; ##-- and don't DESTROY() the clone...
  #  return;
  #}

  ##-- we must make a *real* new object: $fsmnew
  my $fsmnew = ref($fsm)->new();
  $$fsm    = $$fsmnew;
  $$fsmnew = 0;                ##-- ... but not destroy it...
  undef($fsmnew);

  ##-- now do the actual deed
  $fsm->load_string(${$_[3]})
    or croak(ref($fsm)."::STORABLE_thaw(): error loading from string: $Gfsm::Error\n");
}
package main;


##--------------------------------------------------------------
## Viterbi

sub vload {
  $vlo = Gfsm::Alphabet->new(); $vlo->load('vit-lower.lab');
  $vhi = Gfsm::Alphabet->new(); $vhi->load('vit-upper.lab');
  $vq  = Gfsm::Alphabet->new(); $vq->load('vit-states.lab');

  $vfsm = Gfsm::Automaton->new();
  $vfsm->compile('vit.tfst',lower=>$vlo,upper=>$vhi,states=>$vq);
}

sub vtest {
  my $istr  = shift;
  $istr = 'aaab' if (!$istr);
  our $ilabs = $vlo->string_to_labels($istr);
  our $trellis = $vfsm->shadow;

  $vfsm->lookup_viterbi($ilabs, $trellis);
  our $vpaths = $trellis->viterbi_trellis_paths($Gfsm::LSBoth);
  our $vbest  = $trellis->viterbi_trellis_bestpath($Gfsm::LSBoth);
}

sub vpaths {
  return map { (sprintf("<%.2f> ", $_->{w})
		.$vlo->labels_to_string(defined($_->{lo}) ? $_->{lo} : '')
		." : "
		.$vhi->labels_to_string(defined($_->{hi}) ? $_->{hi} : '')
	       )
	     } @_;
}

sub vview { $vfsm->viewps(vlabargs(),states=>$vq,@_); }
sub vtview { $trellis->viewps(vlabargs(),@_); }
sub vlabargs { return (lower=>$vlo,upper=>$vhi); }

##--------------------------------------------------------------
## Tries

sub gentrie {
  $trie = Gfsm::Automaton->newTrie();
  $trie->add_paths($_,[], 1, 1,0,1) foreach ([1,2,3],[1,2],[1,2,1],[1,1,1]);
}

sub viewtrie {
  $trie->viewps((defined($abet) ? (labels=>$abet) : qw()), @_);
}

##--------------------------------------------------------------
## Tries: benchmarking
sub genpaths {
  eval "use Benchmark;";
  Benchmark->import(qw(timethese cmpthese));
  our $nchars  = 32 if (!$nchars);
  our $pathlen = 8  if (!$pathlen);
  our $npaths  = 2048 if (!$npaths);
  our @paths = map {
    [map { int(rand($nchars))+1 } (0..$pathlen)]
  } (1..$npaths);
}
sub gentries {
  our $trie_c    = Gfsm::Automaton->newTrie;
  our $trie_perl = Gfsm::Automaton->newTrie;
}

sub trie_add_path_perl {
  my $trie = $trie_perl;
  my $labs = shift;
  my $qid = $trie->root;
  $qid = $trie->root($trie->add_state(0)) if ($qid==$Gfsm::noState);
  foreach (@$labs) {
    $qid = $trie->get_arc_lower($qid,$_, 1,1);
  }
  $trie->final_weight($qid, $trie->final_weight($qid)+1);
  return $qid;
}
sub trie_add_path_c { return $trie_c->add_path($_[0],[], 1, 1,0,1); }

sub trie_dummies {
  gentries;
  @paths = ([1,2,3],[1,1,1],[1,2,1],[1,2]) if (!@paths);
  foreach $path (@paths) {
    trie_add_path_perl($path);
    trie_add_path_c($path);
  }
}
#trie_dummies;

sub trie_add_all_perl { trie_add_path_perl($_) foreach (@paths); }
sub trie_add_all_c    { trie_add_path_c($_) foreach (@paths); }
main_dummy();

##--------------------------------------------------------------
## MAIN
package main;
sub storetest {
  require Storable;
  loadfsm();
  use vars qw($fsm_f $fsm_t);
  $fsm_f = Storable::freeze($fsm);
  $fsm_t = Storable::thaw($fsm_f);
}


##-- dummy
sub main_dummy {
  foreach $i (0..10) {
    print "--dummy($i)--\n";
  }
}
main_dummy();

