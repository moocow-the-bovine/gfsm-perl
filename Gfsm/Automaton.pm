package Gfsm::Automaton;
require Gfsm::Alphabet;

use IO::File;
use File::Temp qw(tempfile);
use Carp;

##======================================================================
## Constants
##======================================================================
our $NULL = bless \(my $x=0), 'Gfsm::Automaton';
our $GV   = 'gv';
our $DOT  = 'dot';

##======================================================================
## I/O: Wrappers
##======================================================================

##--------------------------------------------------------------
## I/O: Wrappers: Binary

## $bool = $fsm->load($filename_or_fh);
sub load {
  my ($fsm,$file) = @_;
  my $fh = ref($file) ? $file : IO::File->new("<$file");
  if (!$fh) {
    carp(ref($fsm),"::load(): could not open file '$file': $!");
    return 0;
  }
  my $rc = $fsm->_load($fh);
  carp(ref($fsm),"::load(): error loading file '$file': $Gfsm::Error\n") if (!$rc);
  $fh->close() if (!ref($file));
  return $rc;
}

## $bool = $fsm->save($filename_or_fh);
sub save {
  my ($fsm,$file) = @_;
  my $fh = ref($file) ? $file : IO::File->new(">$file");
  if (!$fh) {
    carp(ref($fsm),"::save(): could not open file '$file': $!");
    return 0;
  }
  my $rc = $fsm->_save($fh);
  carp(ref($fsm),"::save(): error saving file '$file': $Gfsm::Error\n") if (!$rc);
  $fh->close() if (!ref($file));
  return $rc;
}

##--------------------------------------------------------------
## I/O: Wrappers: Text

## $bool = $fsm->compile($filename_or_fh,%opts);
##  + %opts:
##     lower => $alphabet_lower,
##     upper => $alphabet_upper,
##     states => $alphabet_states,
sub compile {
  my ($fsm,$file,%opts) = @_;
  my $fh = ref($file) ? $file : IO::File->new("<$file");
  if (!$fh) {
    carp(ref($fsm),"::compile(): could not open file '$file': $!");
    return 0;
  }
  my $rc = $fsm->_compile($fh,
			  ($opts{lower} ? $opts{lower} : $Gfsm::Alphabet::NULL),
			  ($opts{upper} ? $opts{upper} : $Gfsm::Alphabet::NULL),
			  ($opts{states} ? $opts{states} : $Gfsm::Alphabet::NULL));
  carp(ref($fsm),"::compile(): error compiling file '$file': $Gfsm::Error\n") if (!$rc);
  $fh->close() if (!ref($file));
  return $rc;
}

## $bool = $fsm->print_att($filename_or_fh, %opts);
##  + %opts:
##     lower => $alphabet_lower,
##     upper => $alphabet_upper,
##     states => $alphabet_states,
sub print_att {
  my ($fsm,$file,%opts) = @_;
  my $fh = ref($file) ? $file : IO::File->new(">$file");
  if (!$fh) {
    carp(ref($fsm),"::print_att(): could not open file '$file': $!");
    return 0;
  }
  my $rc = $fsm->_print_att($fh,
			    ($opts{lower} ? $opts{lower} : $Gfsm::Alphabet::NULL),
			    ($opts{upper} ? $opts{upper} : $Gfsm::Alphabet::NULL),
			    ($opts{states} ? $opts{states} : $Gfsm::Alphabet::NULL));
  carp(ref($fsm),"::print_att(): error saving text file '$file': $Gfsm::Error\n") if (!$rc);
  $fh->close() if (!ref($file));
  return $rc;
}

##--------------------------------------------------------------
## I/O: Wrappers: Draw

## $bool = $fsm->draw_vcg($filename_or_fh, %opts);
##  + %opts:
##     lower => $alphabet_lower,
##     upper => $alphabet_upper,
##     labels => $alphabet_lower_and_upper,
##     states => $alphabet_states,
##     title => $title,
##     xspace=>$xspace,
##     yspace=>$yspace,
##     orientation=>$orient,
##     state_shape=>$shape,
##     state_color=>$color,
##     final_color=>$color,
sub draw_vcg {
  my ($fsm,$file,%opts) = @_;
  my $fh = ref($file) ? $file : IO::File->new(">$file");
  if (!$fh) {
    carp(ref($fsm),"::draw_vcg(): could not open file '$file': $!");
    return 0;
  }
  my $rc = $fsm->_draw_vcg($fh,
			   ($opts{lower} ? $opts{lower} : ($opts{labels} ? $opts{labels} : $Gfsm::Alphabet::NULL)),
			   ($opts{upper} ? $opts{upper} : ($opts{labels} ? $opts{labels} : $Gfsm::Alphabet::NULL)),
			   ($opts{states} ? $opts{states} : $Gfsm::Alphabet::NULL),
			   ($opts{title} ? $opts{title} : "$fsm"),
			   (defined($opts{xspace}) ? $opts{xspace} : 40),
			   (defined($opts{yspace}) ? $opts{yspace} : 20),
			   ($opts{orientation} ? $opts{orientation} : 'left_to_right'),
			   ($opts{state_shape} ? $opts{state_shape} : 'box'),
			   ($opts{state_color} ? $opts{state_color} : 'white'),
			   ($opts{final_color} ? $opts{final_color} : 'lightgrey'));
  carp(ref($fsm),"::draw_vcg(): error saving text file '$file': $Gfsm::Error\n") if (!$rc);
  $fh->close() if (!ref($file));
  return $rc;
}


## $bool = $fsm->draw_dot($filename_or_fh, %opts);
##  + %opts:
##     lower => $alphabet_lower,
##     upper => $alphabet_upper,
##     labels => $alphabet_lower_and_upper,
##     states => $alphabet_states,
##     title => $title,
##     width=>$inches,
##     height=>$inches,
##     fontsize=>$points,
##     fontname=>$font,
##     portrait=>$bool,
##     vertical=>$bool,
##     nodesep=>$distance,
##     ranksep=>$distance,
sub draw_dot {
  my ($fsm,$file,%opts) = @_;
  my $fh = ref($file) ? $file : IO::File->new(">$file");
  if (!$fh) {
    carp(ref($fsm),"::draw_dot(): could not open file '$file': $!");
    return 0;
  }
  my $rc = $fsm->_draw_dot($fh,
			   ($opts{lower} ? $opts{lower} : ($opts{labels} ? $opts{labels} : $Gfsm::Alphabet::NULL)),
			   ($opts{upper} ? $opts{upper} : ($opts{labels} ? $opts{labels} : $Gfsm::Alphabet::NULL)),
			   ($opts{states} ? $opts{states} : $Gfsm::Alphabet::NULL),
			   ($opts{title} ? $opts{title} : "$fsm"),
			   ($opts{width} ? $opts{width} : 8.5),
			   ($opts{height} ? $opts{height} : 11),
			   ($opts{fontsize} ? $opts{fontsize} : 14),
			   ($opts{fontname} ? $opts{fontname} : ''),
			   ($opts{portrait} ? $opts{portrait} : 0),
			   ($opts{vertical} ? $opts{vertical} : 0),
			   ($opts{nodesep} ? $opts{nodesep} : 0.25),
			   ($opts{ranksep} ? $opts{ranksep} : 0.40)
			  );
  carp(ref($fsm),"::draw_dot(): error saving text file '$file': $Gfsm::Error\n") if (!$rc);
  $fh->close() if (!ref($file));
  return $rc;
}


##======================================================================
## Visualization
##======================================================================

## undef = $fsm->viewps(%opts)
##   %opts: as for draw_dot()
sub viewps {
  my ($fsm,%opts) = @_;
  my ($fh,$dotfilename,$psfilename);
  ($fh,$dotfilename) = tempfile("gfsmXXXXX", SUFFIX=>'.dot', UNLINK=>1);
  $fh->close;
  if (!$fsm->draw_dot($dotfilename,%opts)) {
    carp(ref($fsm),"::viewps(): draw_dot(): Error\n");
    return;
  }
  $fh->close;
  ($fh,$psfilename) = tempfile("gfsmXXXXX", SUFFIX=>'.ps', UNLINK=>1);
  if (system("$DOT -Tps -o$psfilename $dotfilename")!=0) {
    carp(ref($fsm),"::viewps(): dot: Error: $!");
    return;
  }
  if (system("$GV $psfilename")!=0) {
    carp(ref($fsm),"::viewps(): gv: Error: $!");
    return;
  }
}


##======================================================================
## Algebra: Wrappers
##======================================================================

sub closure   { my $fsm=shift->clone; $fsm->_closure(@_); return $fsm;}
sub n_closure { my $fsm=shift->clone; $fsm->_n_closure(@_); return $fsm;}
sub complement { my $fsm=shift->clone; $fsm->_complement(@_); return $fsm;}
sub complete { my $fsm=shift->clone; $fsm->_complete(@_); return $fsm;}
sub compose_full {
  my ($fsm1,$fsm2,$fsmout) = @_;
  $fsmout = $fsm1->shadow() if (!$fsmout);
  $fsm1->_compose_full($fsm2,$fsmout);
  return $fsmout;
}
sub compose {my $fsm=shift->clone; $fsm->_compose(@_); return $fsm;}
sub concat { my $fsm=shift->clone; $fsm->_concat(@_); return $fsm;}
sub determinize {
  my $nfa=shift;
  my $dfa = $nfa->shadow;
  $nfa->_determinize_full($dfa);
  return $dfa;
}
sub difference_full {
  my ($fsm1,$fsm2,$fsmout) = @_;
  $fsmout = $fsm1->shadow() if (!$fsmout);
  $fsm1->_difference_full($fsm2,$fsmout);
  return $fsmout;
}
sub difference {my $fsm=shift->clone; $fsm->_difference(@_); return $fsm;}
sub intersect_full {
  my ($fsm1,$fsm2,$fsmout) = @_;
  $fsmout = $fsm1->shadow() if (!$fsmout);
  $fsm1->_intersect_full($fsm2,$fsmout);
  return $fsmout;
}
sub intersect {my $fsm=shift->clone; $fsm->_intersect(@_); return $fsm;}
sub invert {my $fsm=shift->clone; $fsm->_invert(@_); return $fsm;}
sub product {my $fsm=shift->clone; $fsm->_product(@_); return $fsm;}
sub project {my $fsm=shift->clone; $fsm->_project(@_); return $fsm;}
sub connect {my $fsm=shift->clone; $fsm->_connect(@_); return $fsm;}
sub reverse {my $fsm=shift->clone; $fsm->_reverse(@_); return $fsm;}
sub rmepsilon {my $fsm=shift->clone; $fsm->_rmepsilon(@_); return $fsm;}
sub union {my $fsm=shift->clone; $fsm->_union(@_); return $fsm;}

##======================================================================
## Lookup: Wrappers
##======================================================================

sub lookup {
  my ($fst,$input,$result) = @_;
  $result = $fst->shadow() if (!$result);
  $fst->_lookup($input,$result);
  return $result;
}

1;

__END__

# Below is stub documentation for your module. You'd better edit it!

=pod

=head1 NAME

Gfsm::Automaton - object-oriented interface to libgfsm finite-state automata

=head1 SYNOPSIS

 use Gfsm;

 ##------------------------------------------------------------
 ## Constructors, etc.

 $fsm = Gfsm::Automaton->new();
 $fsm = Gfsm::Automaton->new($is_transducer,$srtype,$n_preallocated_states);

 $fsm2 = $fsm->clone();     # copy constructor
 $fsm2 = $fsm->shadow();    # copy non-structural elements
 $fsm2->assign($fsm1);      # assigns $fsm1 to $fsm2

 $fsm->clear();             # clear automaton structure

 ##------------------------------------------------------------
 ## Accessors/Manipulators: Properties

 $bool = $fsm->is_transducer();           # get 'is_transducer' flag
 $bool = $fsm->is_transducer($bool);      # ... or set it

 $bool = $fsm->is_weighted(?$bool);       # get/set 'is_weighted' flag
 $mode = $fsm->sort_mode(?$mode);         # get/set sort-mode flag (dangerous)
 $bool = $fsm->is_deterministic(?$bool);  # get/set 'is_deterministic' flag (dangerous)
 $srtype = $fsm->semiring_type(?$srtype); # get/set semiring type

 $n = $fsm->n_states();                   # get number of states
 $n = $fsm->n_final_states();             # get number of final states
 $n = $fsm->n_arcs();                     # get number of arcs

 $id = $fsm->root(?$id);                  # get/set id of initial state

 $bool = $fsm->has_state($id);            # check whether a state exists
 $bool = $fsm->is_cyclic();               # check for cyclicity

 ##------------------------------------------------------------
 ## Accessors/Manipulators: States
 $id = $fsm->add_state();                 # add a new state
 $id = $fsm->ensure_state($id);           # ensure that a state exists

 $fsm->remove_state($id);                 # remove a state from an FSM

 $bool = $fsm->is_final($id,?$bool);      # get/set final-flag for state $id
 $fsm->renumber_states();                 # close gaps in stateid numbering

 ##------------------------------------------------------------
 ## Accessors/Manipulators: Arcs

 $fsm->add_arc($fsm,$id_from,$id_to,$lab_lo,$lab_hi,$weight); # add an arc
 $fsm->arcsort($fsm,$mode);                                   # sort automaton arcs

 $ai = Gfsm::ArcIter->new();              # create new arc-iterator
 $ai = Gfsm::ArcIter->new($fsm,$stateid); # create & open

 $ai->open($fsm,$stateid);                # open outgoing arcs from $stateid in $fsm
 $ai->reset();                            # reset to 1st outgoing arc
 $ai->close();                            # close an arc iterator

 $bool = $ai->ok();                       # check iterator validity
 $ai->remove();                           # remove current arc from the automaton

 $stateid = $ai->target(?$stateid);       # get/set current arc target StateId
 $lab     = $ai->lower(?$lab);            # get/set current arc lower label
 $lab     = $ai->upper(?$lab);            # get/set current arc upper label
 $lab     = $ai->weight(?$lab);           # get/set current arc weight

 $ai->next();                             # increment to next outgoing arc
 $ai->seek_lower($lab);                   # (inclusive) seek next arc with lower label $lab
 $ai->seek_upper($lab);                   # (inclusive) seek next arc with upper label $lab
 $ai->seek_both($lo,$hi);                 # (inclusive) seek next arc with labels $lo,$hi

 ##--------------------------------------------------------------
 ## I/O

 $bool = $fsm->load($filename_or_handle);   # load binary file
 $bool = $fsm->save($filename_or_handle);   # save binary file

 $bool = $fsm->compile($filename_or_handle, ?$abet_lo, ?$abet_hi, ?$abet_states);
         # compile AT&T-style text file (must be transducer format)

 $bool = $fsm->print_att($filename_or_handle, ?$abet_lo, ?$abet_hi, ?$abet_states);
         # save AT&T-style text file (transducer format)

 $bool = $fsm->draw_vcg($filename_or_handle,%options);  # save in VCG format
 $bool = $fsm->draw_dot($filename_or_handle,%options);  # save in DOT format

 $bool = $fsm->viewps(%options);                        # for debugging

 ##--------------------------------------------------------------
 ## Algebra (constructive)

 $fsm = $fsm1->closure();     # reflexive + transitive closure
 $fsm = $fsm1->closure(1);    # transitive closure
 $fsm = $fsm1->n_closure($n); # n-ary closure

 $fsm = $fsm1->complement();      # lower complement wrt. internal alphabet
 $fsm = $fsm1->complement($abet); # lower complement wrt. alphabet $abet

 $sinkid = $fsm->complete($abet); # complete lower wrt. $abet, returns sink-state Id

 $fsm = $fsm1->compose($fsm2);    # transducer composition

 $fsm = $fsm1->concat($fsm2);     # concatenate automata

 $fsm = $fsm1->connect();         # remove non co-accessible states

 $fsm = $fsm1->determinize();     # acceptor determinization

 $fsm = $fsm1->difference($fsm2); # lower difference

 $fsm = $fsm1->intersect($fsm2);  # lower acceptor intersection

 $fsm = $fsm1->invert();          # invert transdcuer sides

 $fsm = $fsm1->product($fsm2);    # compute Cartesian product of acceptors

 $fsm = $fsm1->project($side);    # project 1 side of a transducer

 $fsm = $fsm1->rmepsilon();       # remove epsilon-arcs

 $fsm = $fsm1->union($fsm2);      # compute automaton union

 ##--------------------------------------------------------------
 ## Algebra ((pseudo-)destructive)

 $fsm->_closure();                # destructive closure
 #... etc.

 ##--------------------------------------------------------------
 ## Lookup & Path Enumeration
 $fsm   = $fst->lookup($labs);    # linear composition: $fsm=compose(id($labs),$fst)
 $paths = $fsm->paths();          # enumerate paths (non-cyclic $fsm only!)


=head1 DESCRIPTION

Not yet written.

=cut

########################################################################
## FOOTER
########################################################################

=pod

=head1 BUGS AND LIMITATIONS

Probably many.

=head1 SEE ALSO

Gfsm(3perl),
gfsmutils(1).


=head1 AUTHOR

Bryan Jurish E<lt>moocow@ling.uni-potsdam.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Bryan Jurish

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut