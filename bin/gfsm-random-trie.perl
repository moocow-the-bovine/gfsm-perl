#!/usr/bin/perl -w

use Gfsm;
use Pod::Usage;
use Getopt::Long qw(:config no_ignore_case);
use File::Basename qw(basename);

##======================================================================
## Defaults

our $prog    = basename($0);
our $VERSION = 0.01;

our ($help,$version);

##-- options: I/O
our $outfile = '-';
our $zlevel  = -1;

##-- options: topology
our $acceptor = 0;
our $epsilon  = 1;

our $n_states = 8; ##-- advisory only
our $n_labels = 2; ##-- including epsilon, if specified

our $w_min = 0;
our $w_max = 0;

our $d_min = 0;
our $d_max = 8;

our $n_xarcs  = 0; ##-- number of cross-arcs (non-cyclic)
our $n_cycles = 0; ##-- number of cycles
our $cl_min    = 1;     ##-- minimum cycle length (including cyclic arc; should be >= 1)
our $cl_max    = undef; ##-- maximum cycle length (default=$d_max+1)

our $seed = undef;

##======================================================================
## Command-Line
GetOptions(##-- General
	   'help|h'    => \$help,
	   'version|V' => \$version,

	   ##-- Topology
	   'seed|srand|r=i'  => \$seed,
	   'acceptor|fsa|A!' => \$acceptor,
	   'transducer|fst|T!' => sub { $acceptor=!$_[1]; },

	   'epsilon|eps|e!' => \$epsilon,

	   'n-labels|labels|l=i' => \$n_labels,
	   'n-states|states|q=i' => \$n_states,

	   'min-weight|wmin|w=f' => \$w_min,
	   'max-weight|wmax|W=f' => \$w_max,

	   'min-depth|dmin|d=i' => \$d_min,
	   'max-depth|dmax|D=i' => \$d_max,

	   'n-xarcs|xarcs|x|a=i' => \$n_xarcs,
	   'n-cycles|cycles|c=i' => \$n_cycles,
	   'min-cycle-length|clmin|y=i'  => \$cl_min,
	   'max-cycle-length|clmax|Y=i'  => \$cl_max,

	   ##-- I/O
	   'output|o|F=s' => \$outfile,
	   'compress|z=i' => \$zlevel,
	  );

pod2usage({-exitval=>0, -verbose=>0}) if ($help);

if ($version) {

  print STDERR
    ("${prog} v$VERSION by Bryan Jurish <moocow\@cpan.org>\n",
    );
  exit(0);
}


##======================================================================
## Main
srand($seed) if (defined($seed));

##-- sanity checks
die "cannot generate fsm with n_states > n_labels**max_depth"
  if ($n_states > $n_labels**$d_max);

our $fsm = Gfsm::Automaton->newTrie();
$fsm->is_transducer(!$acceptor);
$fsm->is_weighted(1);
$fsm->semiring_type($Gfsm::SRTTropical);

##-- not quite so stupid way
($w_min,$w_max) = sort ($w_min,$w_max);
our $w_rng = $w_max-$w_min;
our $l_min = $epsilon ? 0 : 1;

##-- generate base trie
my (@lo,@hi,$len,$q);
while ($fsm->n_states() < $n_states) {
  $len = $d_min+int(rand(1+$d_max-$d_min));
  @lo = map {$l_min+int(rand($n_labels))} (1..$len);
  $q = $fsm->add_path(\@lo, \@hi, 0);
}

##-- mark unsorted (avoid "smart" arc insertion)
$fsm->sort_mode(Gfsm::ASMNone());
our $nq = $fsm->n_states();

## ($qpath,$lpath) = qpaths($q)   ##-- list context
##  $qpath         = qpaths($q)   ##-- scalar context
##  +  returns paths to $q in trie as:
##      $qpath = [$q0,$q1,...,$q ]
##      $lpath = [    $l1,...,$lN]
our $rfsm = $fsm->reverse();
my $qpai = Gfsm::ArcIter->new();
*qpath = \&qpaths;
sub qpaths {
  my $q = shift;
  my ($qp,$lp) = ([$q],[]);
  my $r = $q;
  while ($r != 0) {
    $qpai->open($rfsm,$r);
    $r = $qpai->target;
    push(@$qp,$r);
    push(@$lp,$qpai->lower);
  }
  @$qp = reverse @$qp;
  @$lp = reverse @$lp;
  return wantarray ? ($qp,$lp) : $qp;
}

##-- introduce cycles
$cl_min = 1        if ($cl_min <= 0);
$cl_max = $d_max+1 if (!defined($cl_max) || $cl_max<=0);
for (my $nc=0; $nc<$n_cycles; ) {
  $q  = int(rand($nq));
  $qp = qpath($q);
  $qpi_max = @$qp-$cl_min;                       ##-- potential cycle-target states r with len(r-*->q)+1 >= min_cycle_len
  $qpi_min = @$qp>$cl_max ? (@$qp-$cl_max) : 0;  ##-- potential cycle-target states r with len(r-*->q)+1 <= max_cycle_len
  next if ($qpi_min > $qpi_max);                 ##-- potential infloop!
  $r = $qp->[$qpi_min+int(rand(1+$qpi_max-$qpi_min))];
  $a = $l_min+int(rand($n_labels));
  $fsm->add_arc($q,$r, $a,$a,0);
  ++$nc;
}

##-- add non-cyclic arcs
for ($i=0; $i<$n_xarcs; ++$i) {
  $q = int(rand($nq-1));
  $r = 1 + $q + int(rand($nq-$q-1));
  $a = $l_min+int(rand($n_labels));
  $fsm->add_arc($q,$r, $a,$a, 0);
}

##-- randomize weights & upper arc labels
my $ai = Gfsm::ArcIter->new();
if ($w_min!=0 || $w_max!=0 || !$acceptor) {
  for ($q=0; $q < $fsm->n_states(); ++$q) {
    $fsm->final_weight($q,$w_min+($w_rng>0 ? rand($w_rng) : 0)) if ($fsm->is_final($q));
    for ($ai->open($fsm,$q); $ai->ok(); $ai->next()) {
      $ai->weight($w_min+($w_rng>0 ? rand($w_rng) : 0));
      $ai->upper($l_min+int(rand($n_labels))) if (!$acceptor);
    }
  }
}



#$fsm->renumber_states();

##-- dump
$fsm->save($outfile,$zlevel)
  or die("$prog: save failed to gfsm file '$outfile': $!");


__END__

##======================================================================
## Pods
=pod

=pod

=head1 NAME

gfsm-random-trie.perl - create a random trie-based FSM

=head1 SYNOPSIS

 gfsm-random-trie.perl [OPTIONS]

 General Options:
  -help
  -version

 Topology Options:
  -seed SEED                # random seed (default: none)
  -acceptor , -transducer   # build FSA or FST (default=-transducer)
  -epsilon  , -noepsilon    # do/don't include epsilon labels (default=-epsilon)
  -n-labels=N               # alphabet size (default=2)
  -n-states=N               # minimum number of states (default=8)
  -min-weight=W             # minimum weight (default=0)
  -max-weight=W             # maximum weight (default=0)
  -min-depth=DMIN           # minimum successful path length (default=0)
  -max-depth=DMAX           # maximum successful path length (default=8)
  -n-cycles=N               # number of cyclic arcs added to skeleton (default=0)
  -min-cycle-length=YMIN    # minimum cycle length (default=0)
  -max-cycle-length=YMAX    # maximum cycle length (default=MAX_DEPTH)
  -n-xarcs=N                # number of random non-cyclic arcs added to skeleton (default=0)

 I/O Options:
  -zlevel=ZLEVEL            # zlib compression level
  -output=GFSMFILE          # output automaton

=cut

##==============================================================================
## Description
##==============================================================================
=pod

=head1 DESCRIPTION

Not yet written.

=cut

##======================================================================
## Footer
##======================================================================

=pod

=head1 ACKNOWLEDGEMENTS

Perl by Larry Wall.

=head1 AUTHOR

Bryan Jurish E<lt>moocow@cpan.org<gt>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Bryan Jurish

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.

=head1 SEE ALSO

perl(1),
Gfsm(3perl)

=cut

