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

##-- Extraction
our $outfile = '-';

our ($cost_match,$cost_insert,$cost_delete,$cost_subst) = (0,1,1,1);
our $numeric  = 1;
our $max_cost = undef;
our $delayed_action = undef;

##======================================================================
## Command-Line
GetOptions(##-- General
	   'help|h'    => \$help,
	   'version|V' => \$version,

	   ##-- Costs
	   'cost-match|match|m=s'   => \$cost_match,
	   'cost-insert|insert|i=s' => \$cost_insert,
	   'cost-delete|delete|d=s' => \$cost_delete,
	   'cost-substitute|substitute|subst|s=s' => \$cost_subst,

	   ##-- Editor Topology
	   'max-cost|M=s'           => \$max_cost,
	   'delayed-action|da'     => \$delayed_action,
	   'no-delayed-action|no-delayed|immediate-action|immediate' => sub { $delayed_action=0; },

	   ##-- Which ops?
	   'no-substitute|no-subst|S' => sub { undef($cost_subst); },
	   'no-insert|no-ins|I'       => sub { undef($cost_insert); },
	   'no-delete|no-del|D'       => sub { undef($cost_delete); },

	   ##-- I/O
	   'output|o|F=s' => \$outfile,
	  );

pod2usage({-exitval=>0, -verbose=>0}) if ($help);

if ($version) {
  print STDERR
    ("${prog} v$VERSION by Bryan Jurish <moocow\@bbaw.de>\n",
    );
  exit(0);
}

##======================================================================
## Main
our $labfile = @ARGV ? shift(@ARGV) : '-';
our $abet = Gfsm::Alphabet->new();
$abet->load($labfile) or die("$prog: load failed for alphabet file '$labfile': $!");

##-- get labels
our $string2id =$abet->asHash;
our $id2string =$abet->asArray;

##======================================================================
## subs: populate state

## %cost2q = ( $cost=>$qid, ... )
our %cost2q = qw();

## $qid = cost2state($cost)
## $qid = cost2state($cost,$IS_DELAYED)
##  + get or insert target state for cost $cost
sub cost2state {
  my ($cost,$delayed) = @_;
  my $key = (
	     (defined($max_cost) ? $cost : 'no_max')
	     .
	     ($delayed ? ':DELAYED' : '')
	    );
  return $cost2q{$key} if (defined($cost2q{$key}));
  return 0 if (!defined($max_cost) && !$delayed);
  return undef if (defined($max_cost) && $cost > $max_cost);
  our ($fsm);
  my $q = $cost2q{$key} = $fsm->add_state;
  if (!$delayed) { $fsm->final_weight($q,0); }
  return $q;
}

## populate_queue: ($qid=>$cost_at_qid, ...)
our %populate_queue = qw();

## %delayed_arcs_in  = ("${q_src} --${lo}:eps--> ${q_del} <${cost}>"=> undef)
##  + s.t. there exists an arc ${q_src} --${lo}:eps--> ${q_del} <$cost>
our %delayed_arcs_in  = qw();

## %delayed_arcs_out = ("${q_del} --${hi}:eps--> ${q_dst} <0>" => undef)
##  + s.t. there exists an arc ${q_del} --eps:${hi}--> ${q_dst} <0>
our %delayed_arcs_out = qw();

## undef = add_editor_path($fsm, $qid_src, $qid_dst, $lo, $hi, $cost)
##  + add a path in $fsm from $qid_src to $qid_dst on labels ($lo,$hi) with weight $cost
##  + for immediate-action editors (option '-no-delayed-action'), this is equivalend to $fsm->add_arc(@_)
sub add_editor_path {
  my ($fsm,$q_src,$q_dst,$lo,$hi,$cost) = @_;
  ##
  ##-- check for immediate action, match-, or delete-operation arcs
  if (!$delayed_action || $lo==$hi || $hi==$Gfsm::epsilon) {
    $fsm->add_arc($q_src,$q_dst,$lo,$hi,$cost);
    return;
  }
  ##
  ##-- delayed action: get intermediate state
  my $q_del = cost2state($cost,1);
  if (!exists($delayed_arcs_in{"${q_src} --${lo}:eps--> ${q_src} <$cost>"})) {
    $delayed_arcs_in{"${q_src} --${lo}:eps--> ${q_src} <$cost>"} = undef;
    $fsm->add_arc($q_src, $q_del, $lo, $Gfsm::epsilon, $cost);
  }
  if (!exists($delayed_arcs_out{"${q_del} --eps:${hi}--> ${q_dst} <0>"})) {
    $delayed_arcs_out{"${q_del} --eps:${hi}--> ${q_dst} <0>"} = undef;
    $fsm->add_arc($q_del, $q_dst, $Gfsm::epsilon, $hi, 0);
  }
}


## undef = populate_state($fsm,$qid,$accumulated_cost)
sub populate_state {
  my ($fsm,$qid,$cost_this) = @_;
  my ($i, $q_nxt, $cost_nxt);
  our (@labs);

  foreach $i (0..$#labs) {
    if (defined($cost_match))  {
      $cost_nxt = $cost_this + $cost_match;
      if (defined($q_nxt = cost2state($cost_nxt))) {
	add_editor_path($fsm, $qid, $q_nxt, $labs[$i], $labs[$i], $cost_match);
	$populate_queue{$q_nxt}=$cost_nxt;
      }
    }
    if (defined($cost_insert)) {
      $cost_nxt = $cost_this + $cost_insert;
      if (defined($q_nxt = cost2state($cost_nxt))) {
	add_editor_path($fsm, $qid, $q_nxt, 0, $labs[$i], $cost_insert);
	$populate_queue{$q_nxt}=$cost_nxt;
      }
    }
    if (defined($cost_delete)) {
      $cost_nxt = $cost_this + $cost_delete;
      if (defined($q_nxt = cost2state($cost_nxt))) {
	add_editor_path($fsm, $qid, $q_nxt, $labs[$i], 0, $cost_delete);
	$populate_queue{$q_nxt}=$cost_nxt;
      }
    }
    if (defined($cost_subst)) {
      foreach $j (0..$#labs) {
	next if ($j==$i);
	$cost_nxt = $cost_this + $cost_subst;
	if (defined($q_nxt = cost2state($cost_nxt))) {
	  add_editor_path($fsm, $qid, $q_nxt, $labs[$i], $labs[$j], $cost_subst);
	  $populate_queue{$q_nxt}=$cost_nxt;
	}
      }
    }
  }
}


##======================================================================
## Create FSM
our $fsm = Gfsm::Automaton->new();
$fsm->is_transducer(1);
$fsm->is_weighted(1);
$fsm->semiring_type($Gfsm::SRTTropical);

our $q0  = $fsm->ensure_state(0);
$fsm->root(0);
$fsm->final_weight($q0,0);
$cost2q{0} = 0;
$populate_queue{0} = 0;
our %q_done = qw();

our @labs    = grep {$_ != 0} values(%$string2id);
while (grep {!exists($q_done{$_})} keys(%populate_queue)) {
  $q = (grep {!exists($q_done{$_})} keys(%populate_queue))[0];
  populate_state($fsm,$q,$populate_queue{$q});
  $q_done{$q} = 1;
}

##-- save
$fsm->save($outfile)
  or die("$prog: save failed to gfsm file '$outfile': $!");


__END__

##======================================================================
## Pods
=pod

=pod

=head1 NAME

gfsm-make-editor.perl - make a Fischer-Wagner style editor FST

=head1 SYNOPSIS

 gfsm-make-editor.perl [OPTIONS] LABELS_FILE

 General Options:
  -help
  -version

 Cost Options:
  -cost-match  COST         # default=0
  -cost-insert COST         # default=1
  -cost-delete COST         # default=1
  -cost-subst  COST         # default=1

 Editor Topology Options:
  -max-cost    COST         # maximum path cost (default: none)
  -delayed-action           # use weighted epsilon moves to delay insert & substitute hypotheses
  -immediate-action         # don't delay non-match hypotheses (default)

 Operation Selection Options:
  -no-subst                 # don't generate substitution arcs
  -no-insert                # don't generate insertion arcs
  -no-delete                # don't generate deletion arcs

 I/O Options:
  -output      GFSMFILE     # output automaton

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

Bryan Jurish E<lt>moocow@ling.uni-potsdam.deE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Bryan Jurish

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=head1 SEE ALSO

perl(1),
Gfsm(3perl)

=cut

