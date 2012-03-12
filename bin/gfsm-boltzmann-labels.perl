#!/usr/bin/perl -w

use PDL;
use Gfsm;

if (!@ARGV) {
  print STDERR "Usage: $0 NLABELS [GFSMFILE=-]\n";
  exit 1;
}
our $nlabels = shift;

push(@ARGV,'-') if (!@ARGV);
our $fsm = Gfsm::Automaton->new;
my $fsmfile = shift;
$fsm->load($fsmfile) or die("$0: load failed for '$fsmfile': $!");

my $n_arcs = $fsm->n_arcs;
my $beta = 1;
my $labp = pdl(2)**(-$beta*sequence($nlabels));
$labp = ($labp / $labp->sumover)->cumusumover;

my $ilabs = random($n_arcs)->vsearch($labp)+1;
my $olabs = random($n_arcs)->vsearch($labp)+1;
my $i=0;
my ($q);
my $ai = Gfsm::ArcIter->new();
for ($q=0; $q < $fsm->n_states; ++$q) {
  for ($ai->open($fsm,$q); $ai->ok(); $ai->next) {
    $ai->lower($ilabs->at($i));
    $ai->upper($olabs->at($i));
    ++$i;
  }
}

##-- dump
$fsm->save(\*STDOUT);

