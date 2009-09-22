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

## %ops: ($op => \%opspec, ..)
##  + where %opspec = ( $cost=>$cost_or_undef, (class_(lo|hi)=>$class), labs_(lo|hi)=>\@labids ),
our %ops = (
	    match  => { cost=>0, class_lo=>'<sigma>' },
	    insert => { cost=>1, class_hi=>'<sigma>' },
	    delete => { cost=>1, class_lo=>'<sigma>' },
	    subst  => { cost=>1, class_lo=>'<sigma>', class_hi=>'<sigma>', },
	   );

our $numeric  = 1;
our $max_cost = undef;
our $delayed_action = undef;

##-- which labels?
our $scl_file = undef; ##-- defualt: none

##======================================================================
## Command-Line
GetOptions(##-- General
	   'help|h'    => \$help,
	   'version|V' => \$version,

	   ##-- Costs
	   'cost-match|match|m=s'   => \$ops{match}{cost},
	   'cost-insert|insert|i=s' => \$ops{insert}{cost},
	   'cost-delete|delete|d=s' => \$ops{delete}{cost},
	   'cost-substitute|substitute|subst|s=s' => \$ops{subst}{cost},

	   ##-- Editor Topology
	   'max-cost|M=s'           => \$max_cost,
	   'delayed-action|da'     => \$delayed_action,
	   'no-delayed-action|no-delayed|immediate-action|immediate' => sub { $delayed_action=0; },

	   ##-- Which labels?
	   'superclasses|super|scl|S=s' => \$scl_file,
	   'class-match|cm=s'=> \$ops{match}{class_lo},
	   'class-insert|ci=s' => \$ops{insert}{class_hi},
	   'class-delete|cd=s' => \$ops{delete}{class_lo},
	   'class-subst-lo|csl=s' => \$ops{subst}{class_lo},
	   'class-subst-hi|csh=s' => \$ops{subst}{class_hi},

	   ##-- Which ops?
	   'no-match|nm' => sub { delete($ops{match}); },
	   'no-substitute|no-subst|ns' => sub { delete($ops{subst}); },
	   'no-insert|no-ins|ni'       => sub { delete($ops{insert}); },
	   'no-delete|no-del|nd'       => sub { delete($ops{delete}); },

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
## Subs: load superclass labels
our %scl = qw(); ## ($classname => \@class_labids, ...)
sub load_scl_file {
  my $file = shift;
  open(SCL,"<$file") || die("$0: open failed for .scl file '$file': $!");
  my ($class,$labid);
  while (<SCL>) {
    chomp;
    ($class,$labid) = split(/\s+/,$_);
    next if (!defined($class) || !defined($labid));
    push(@{$scl{$class}},$labid);
  }
  close(SCL);
}


##======================================================================
## Main
our $labfile = @ARGV ? shift(@ARGV) : '-';
our $abet = Gfsm::Alphabet->new();
$abet->load($labfile) or die("$prog: load failed for alphabet file '$labfile': $!");

##-- load labels
our $string2id =$abet->asHash;
our $id2string =$abet->asArray;

##-- load superclass labels
if (defined($scl_file)) {
  load_scl_file($scl_file);
} else {
  $scl{'<sigma>'} = [grep {$_!=0} values(%$string2id)];
}

##-- get operand label-id subsets, populate $ops{$OP}{labs_(lo|hi)}
while (($opname,$op)=each(%ops)) {
  next if (!defined($op)); ##-- ignore
  foreach $side (qw(lo hi)) {
    next if (!defined($class=$op->{"class_$side"}));
    die("$0: no superclass '$class' for operation '$opname' side '$side'") if (!defined($labs=$scl{$class}));
    $op->{"labs_$side"} = $labs;
  }
}

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
  my ($op,$lo,$hi, $q_nxt, $cost_nxt);

  ##-- populate: match
  if (defined($op=$ops{match})) {
    foreach $lo (@{$op->{labs_lo}}) {
      $cost_nxt = $cost_this + $op->{cost};
      if (defined($q_nxt = cost2state($cost_nxt))) {
	add_editor_path($fsm, $qid, $q_nxt, $lo,$lo, $op->{cost});
	$populate_queue{$q_nxt}=$cost_nxt;
      }
    }
  }

  ##-- populate: insert
  if (defined($op=$ops{insert})) {
    foreach $hi (@{$op->{labs_hi}}) {
      $cost_nxt = $cost_this + $op->{cost};
      if (defined($q_nxt = cost2state($cost_nxt))) {
	add_editor_path($fsm, $qid, $q_nxt, 0,$hi, $op->{cost});
	$populate_queue{$q_nxt}=$cost_nxt;
      }
    }
  }

  ##-- populate: delete
  if (defined($op=$ops{delete})) {
    foreach $lo (@{$op->{labs_lo}}) {
      $cost_nxt = $cost_this + $op->{cost};
      if (defined($q_nxt = cost2state($cost_nxt))) {
	add_editor_path($fsm, $qid, $q_nxt, $lo,0, $op->{cost});
	$populate_queue{$q_nxt}=$cost_nxt;
      }
    }
  }

  ##-- populate: substitute
  if (defined($op=$ops{subst})) {
    foreach $lo (@{$op->{labs_lo}}) {
      foreach $hi (@{$op->{labs_hi}}) {
	next if ($hi==$lo);
	$cost_nxt = $cost_this + $op->{cost};
	if (defined($q_nxt = cost2state($cost_nxt))) {
	  add_editor_path($fsm, $qid, $q_nxt, $lo,$hi, $op->{cost});
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
  -no-match                 # don't generate match arcs
  -no-subst                 # don't generate substitution arcs
  -no-insert                # don't generate insertion arcs
  -no-delete                # don't generate deletion arcs

 Operand Selection Options:
  -superclasses SCLFILE     # load lextools(1) superclass labels from SCLFILE
  -class-match    CLASS     # superclass for match  input  (default='<sigma>')
  -class-insert   CLASS     # superclass for insert output (default='<sigma>')
  -class-delete   CLASS     # superclass for delete input  (default='<sigma>')
  -class-subst-lo CLASS     # superclass for subst  input  (default='<sigma>')
  -class-subst-hi CLASS     # superclass for subst  output (default='<sigma>')

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

