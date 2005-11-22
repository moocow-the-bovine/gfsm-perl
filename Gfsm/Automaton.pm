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
## I/O: Wrappers: Dra

## $bool = $fsm->draw_vcg($filename_or_fh, %opts);
##  + %opts:
##     lower => $alphabet_lower,
##     upper => $alphabet_upper,
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
			   ($opts{lower} ? $opts{lower} : $Gfsm::Alphabet::NULL),
			   ($opts{upper} ? $opts{upper} : $Gfsm::Alphabet::NULL),
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
			   ($opts{lower} ? $opts{lower} : $Gfsm::Alphabet::NULL),
			   ($opts{upper} ? $opts{upper} : $Gfsm::Alphabet::NULL),
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
sub concat { my $fsm=shift->clone; $fsm->_concat(@_); return $fsm;}
sub determinize { my $fsm=shift->clone; $fsm->_determinize(@_); return $fsm;}
sub invert {my $fsm=shift->clone; $fsm->_invert(@_); return $fsm;}
sub project {my $fsm=shift->clone; $fsm->_project(@_); return $fsm;}
sub prune {my $fsm=shift->clone; $fsm->_prune(@_); return $fsm;}
sub reverse {my $fsm=shift->clone; $fsm->_reverse(@_); return $fsm;}
sub union {my $fsm=shift->clone; $fsm->_union(@_); return $fsm;}

1;

__END__

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Gfsm::Automaton - object-oriented interface to libgfsm finite-state automata

=head1 SYNOPSIS

  use Gfsm;

  $fsm = Gfsm::Automaton->new();

  ##... stuff happens

=head1 DESCRIPTION

Not yet written.

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
