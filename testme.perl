#!/usr/bin/perl -w

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
## test: compose

sub compose1 {
  my ($fsm1,$fsm2) = @_;
  my $fsm3 = $fsm1->compose($fsm2);
  return $fsm3;
}
sub compose2 {
  my ($fsm1,$fsm2) = @_;

  ##-- Phase 0: prepare composition filter
  my $abet   = $fsm1->alphabet(Gfsm::LSUpper());                # get shared alphabet
  my $filter = $abet->composition_filter($fsm1->semiring_type); # create composition filter

  ##-- hack for viewps: make human-readable labs
  our $labs = Storable::dclone($abet);
  $labs->insert('eps',  Gfsm::epsilon);
  $labs->insert('eps1', Gfsm::epsilon1);
  $labs->insert('eps2', Gfsm::epsilon2);

  ##-- Phase 1: tweak epsilon arcs in shared alphabet
  $fsm1->_compose_prepare_fsm1();   # prepare fsm1 for composition
  $fsm2->_compose_prepare_fsm2();   # prepare fsm2 for composition

  ##-- Phase 2: filter FSM1: fsm1f = compose(fsm1,filter)
  $filter->arcsort(Gfsm::ASMLower());
  my $fsm1f = $fsm1->shadow;
  $fsm1->_compose_guts($filter, $fsm1f);

  ##-- Phase 3: compose filtered fsm1 with fsm2: fsm3 = compose(fsm1f,fsm2)
  $fsm1f->arcsort(Gfsm::ASMUpper());
  my $fsm3 = $fsm1f->shadow;
  $fsm1f->_compose_guts($fsm2, $fsm3);

  ##-- Final: restore original input fsms
  my $sm      = Gfsm::ASMNone;
  my $restore = 1;
  $fsm1->_compose_restore($fsm2, $sm,$sm, $restore,$restore);

  return $fsm3;
}

##-- test
sub test_compose {
  our $fsm1 = Gfsm::Automaton->new();
  $fsm1->root(0);
  $fsm1->add_arc(0,1, 1, 1,  0);
  $fsm1->add_arc(0,1, 2, 2,  0);
  $fsm1->add_arc(1,1, 10,0, 0);
  $fsm1->final_weight(1,0);

  our $fsm2 = Gfsm::Automaton->new();
  $fsm2->root(0);
  $fsm2->add_arc(0,0, 1, 2, 0);
  $fsm2->add_arc(0,0, 2, 3, 0);
  $fsm2->add_arc(0,0, 0,20, 0);
  $fsm2->final_weight(0,0);

  our $c1 = compose1($fsm1,$fsm2);
  our $c2 = compose2($fsm1,$fsm2);

  print "test_compose: done.\n";
}
test_compose;

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


##--------------------------------------------------------------
## object alphabets
package Obj;
sub new {
  my ($that,$val) = @_;
  my $obj = bless \$val, ref($that)||$that;
  print __PACKAGE__, "::new(val=$val) returning $obj\n";
  return $obj;
}
sub DESTROY {
  my $obj = shift;
  print __PACKAGE__, "::DESTROY(obj=$obj,val=$$obj) called.\n";
}
package main;

##--------------------------------------------------------------
## utf8 alphabet woes
package main;
use Encode qw(encode decode);

sub utf8abet {
  our $a = Gfsm::Alphabet->new();
  our ($lab2sym,$sym2lab) = ($a->asArray,$a->asHash);

  $a->get_label('zero'); ##--> 0
  $a->get_label('one');  ##--> 1

  our $wlat1 = 'daß';
  our $wutf8 = decode('latin1',$wlat1);

  our $labu = $a->get_label($wutf8); ##--> 2
  $a->get_label('three');            ##--> 3

  our $labu2 = $a->find_label($wutf8); ## SHOULD BE 2, is gfsmNoLabel !
  if ($labu != $labu2) {
    warn("bad labels $labu/$labu2 for '$wutf8'");
  }
}
utf8abet();

sub obj_abet {
  $a = Gfsm::Alphabet->new();

  use vars qw($obj1 $obj2 $obj1s $obj2s);
  $obj1  = Obj->new('obj1');
  $obj1s = "$obj1";
  $obj2  = Obj->new('obj2');
  $obj2s = "$obj2";
  $lab1  = $a->insert($obj1);
  #$lab1b = $b->insert($obj1);
  undef($obj1);

  #$a->remove_label($lab1); ##-- should decrement $$obj1 reference count!

  $a->insert($obj2, $lab1);
}
#obj_abet();

sub obj_basic_av {
  $obj1  = Obj->new('obj1');
  $a = [];
  Gfsm::addav($a,0,$obj1);
  undef($obj1);
  Gfsm::rmav($a,0);
  @$a = qw();
}
#obj_basic_av();

sub obj_basic_hv {
  $obj1  = Obj->new('obj1');
  $obj1s = "$obj1";
  $h = {};
  Gfsm::addhv($h,$obj1,$obj1);
  undef($obj1);
  Gfsm::rmhv($h,$obj1s);
  %$h=qw();
}
#obj_basic_hv();



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
  foreach $i (0..3) {
    print "--dummy($i)--\n";
  }
}
main_dummy();

