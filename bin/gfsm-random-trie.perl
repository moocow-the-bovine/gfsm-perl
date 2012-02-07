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

##-- stupid way
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

##-- setup weights & upper arc labels
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

gfsm-random-trie.perl - create a random trie

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
  -min-depth=DEPTH          # minimum successful path length (default=0)
  -max-depth=DEPTH          # maximum successful path length (default=8)

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

