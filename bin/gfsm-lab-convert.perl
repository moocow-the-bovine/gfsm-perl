#!/usr/bin/perl -w

use Gfsm;

if (@ARGV < 3) {
  print STDERR "Usage: $0 FST FROM_LABELS TO_LABELS [OUTFILE]\n";
  exit 1;
}

our $fstfile=shift;
our $labfile_from=shift;
our $labfile_to=shift;
our $outfile = @ARGV ? shift(@ARGV) : '-';

##======================================================================
## Subs: messages
sub vmsg   { print STDERR @_; }
sub vmsg1  { print STDERR "$0: ", @_, "\n"; }
sub vmsg1t { print STDERR  "\t", @_, "\n"; }

##======================================================================
## Main: load labels

vmsg("$0: loading alphabets... ");

our $labs_from = Gfsm::Alphabet->new();
$labs_from->load($labfile_from)
  or die("$0: load failed for source alphabet file '$labs_from'");

our $labs_to = Gfsm::Alphabet->new();
$labs_to->load($labfile_to)
  or die("$0: load failed for sink alphabet file '$labs_to'");

vmsg("loaded.\n");

##======================================================================
## Main: translation hash

vmsg("$0: preparing translation map... ");

our @xlate = qw(0);
our %labs_keep = map {($_=>undef)} ($Gfsm::epsilon,$Gfsm::epsilon1,$Gfsm::epsilon2,$Gfsm::noLabel);
my $from2lab = $labs_from->asHash;
my $to2lab   = $labs_to->asHash;
foreach $key (keys(%$from2lab)) {
  $lab_from = $from2lab->{$key};

  ##-- hack: check for special labels
  if (exists($labs_keep{$lab_from})) {
    $xlate[$lab_from] = $lab_from;
    next;
  }

  ##-- translate other labels
  if (!defined($lab_to = $to2lab->{$key})) {
    warn("$0: source label '$key' ($lab_from) not defined in sink file: using NoLabel!");
    $lab_to = $Gfsm::noLabel;
  }

  $xlate[$lab_from] = $lab_to;
}

vmsg("done.\n");

##======================================================================
## Main: load fst

vmsg("$0: loading FST... ");

our $fst = Gfsm::Automaton->new();
$fst->load($fstfile)
  or die("$0: load failed for gfsm file '$fstfile'");

vmsg("loaded.\n");

##======================================================================
## Main: process fst

vmsg("$0: processing... ");

our $ai = Gfsm::ArcIter->new();
my ($qid,$lo,$hi);

foreach $qid (0..($fst->n_states-1)) {
  next if (!$fst->has_state($qid));
  for ($ai->open($fst,$qid); $ai->ok; $ai->next) {
    $ai->lower( $xlate[$ai->lower] );
    $ai->upper( $xlate[$ai->upper] );
  }
}

vmsg("done.\n");

##======================================================================
## Main: save

vmsg("$0: saving output FST... ");
$fst->save($outfile)
  or die("$0: save() failed for FST to file '$outfile': $!");
vmsg("saved.\n");

