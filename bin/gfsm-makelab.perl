#!/usr/bin/perl -w

use Getopt::Long qw(:config no_ignore_case);
use File::Basename qw(basename);
use Pod::Usage;
use strict;

##------------------------------------------------------------------------------
## Constants & Globals
our $prog = basename($0);

our $outbase = undef;
our $labfile = undef;
our $sclfile = undef;
our $want_specials = 0;

##------------------------------------------------------------------------------
## Command-line
our ($help);
GetOptions(##-- General
	   'help|h' => \$help,
	   #'verbose|v=i' => \$verbose,
	   #'quiet|q' => sub { $verbose=0; },

	   ##-- I/O
	   'special-symbols|specials|L' => $want_specials,
	   'output|out|o=s' => \$outbase,
	   'lab-output|labout|lab|lo=s' => \$labfile,
	   'scl-output|sclout|scl|so=s' => \$sclfile,
	  );

pod2usage({-exitval=>0,-verbose=>0,}) if ($help);
pod2usage({-message=>"No input symbol file given!",-exitval=>0,-verbose=>0,}) if (@ARGV < 1);

##------------------------------------------------------------------------------
## escaping

sub unescape {
  my $s = shift;
  $s =~ s/\\n/\n/g;
  $s =~ s/\\r/\r/g;
  $s =~ s/\\t/\t/g;
#  $s =~ s/\\v/\v/g;
  $s =~ s/\\x([0-9a-f]{1,2})/chr($1)/gxi;
  $s =~ s/\\(.)/$1/g;
  return $s;
}

##------------------------------------------------------------------------------
## MAIN

##-- get filenames
our $symfile = shift;
die "$prog: could not read file symbols-file '$symfile' or '$symfile.sym'" if (!-r "$symfile" && !-r"$symfile.sym");
$symfile = "$symfile.sym" if (!-r $symfile);

($outbase = $symfile) =~ s/\.sym$// if (!$outbase);
$labfile = "$outbase.lab" if (!$labfile);
$sclfile = "$outbase.scl" if (!$sclfile);

##-- load symspec

## %cls : ($class => \@syms, ...)
## %cat : ($category => \@features, ...)
## @sym : @all_symbols
my (%cls,%cat,@sym,%sym);
open(my $symfh, "<", $symfile)
  or die("$prog: open failed for '$symfile': $!");
my ($class,@vals);
while (<$symfh>) {
  chomp;
  next if (/^\s*$/);
  ($class,@vals) = map {unescape($_)} split(/\s+/,$_);
  if ($class eq 'Category:') {
    push(@sym, (@sym{@vals}=@vals));
    $cat{$vals[0]} = [@vals[1..$#vals]];
  } else {
    push(@sym, (@sym{@vals}=@vals));
    push(@{$cls{$class}},@vals);
  }
}
close $symfh;

##-- TODO: CONTINUE HERE: expand %cls (fixpoint-like?), then generate

##-- dump (debug)
use Data::Dumper;
print Data::Dumper->Dump([\%cls,\%cat,\@sym],[qw(cls cat sym)]);

__END__

=pod

=head1 NAME

gfsm-makelabe.perl - split lextools symbol specification into *.lab and *.scl

=head1 SYNOPSIS

 gfsm-makelab.perl [OPTIONS] SYMFILE[.sym]

 Options:
  -h , -help                  # this help message
  -L , -special-symbols       # include lextools-style special symbols?
  -o , -output OUTBASE        # specify output basename (default=SYMFILE)
  -lo, -lab-output LABFILE    # specify lab-file output (default=OUTBASE.lab)
  -so, -scl-output SCLFILE    # specify scl-file output (default=OUTBASE.scl)

=cut

##------------------------------------------------------------------------------
## Options and Arguments
##------------------------------------------------------------------------------
=pod

=head1 OPTIONS AND ARGUMENTS

Not yet written.

=cut

##------------------------------------------------------------------------------
## Description
##------------------------------------------------------------------------------
=pod

=head1 DESCRIPTION

Split lextools-style symbol specifications (*.sym) into terminal labels (*.lab) and superclass labels (*.scl).

=cut

##------------------------------------------------------------------------------
## See Also
##------------------------------------------------------------------------------
=pod

=head1 SEE ALSO

perl(1),
...

=cut

##------------------------------------------------------------------------------
## Footer
##------------------------------------------------------------------------------
=pod

=head1 AUTHOR

Bryan Jurish E<lt>moocow@cpan.orgE<gt>

=cut

