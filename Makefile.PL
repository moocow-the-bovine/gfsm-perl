use ExtUtils::MakeMaker;

##----------------------------------------------------------------------
## Configuration
##----------------------------------------------------------------------
if (system("pkg-config --atleast-version=0.0.10 gfsm") != 0) {
  die("Required module gfsm >= v0.0.10 not found!\n");
}

##-- @pthread_flags: flag(s) for pthread (added to both CPPFLAGS and LIBS)
#my @pthread_flags = ('-pthread');
my @pthread_flags = qw();
$GFSM_IFLAGS = join(' ', @pthread_flags, map { $s=`pkg-config --cflags-only-I $_`; chomp($s); $s } qw(gfsm glib-2.0));
$GFSM_LDFLAGS= join(' ',                 map { $s=`pkg-config --libs-only-L $_`; chomp($s); $s } qw(gfsm glib-2.0));
$GFSM_LIBS   = join(' ', @pthread_flags, map { $s=`pkg-config --libs-only-l $_`; chomp($s); $s } qw(gfsm glib-2.0));

##----------------------------------------------------------------------
## MAIN
##----------------------------------------------------------------------
WriteMakefile
  (
   NAME		=> 'Gfsm',
   DISTNAME	=> 'gfsm-perl',
   AUTHOR       => 'Bryan Jurish <moocow@cpan.org>',
   ABSTRACT	=> 'Perl interface to libgfsm finite-state library',
   VERSION_FROM	=> 'Gfsm.pm',


   ##-- user variables
   #CC           => 'c++',   ##-- your c++ compiler
   LIBS         => "$GFSM_LDFLAGS $GFSM_LIBS",      ##-- additional libraries
   DEFINE       => '-DHAVE_CONFIG_H',     ##-- additional defines
   INC          => $GFSM_IFLAGS,      ##-- additional includes
   CCFLAGS      => '',          ##-- additional flags
   OPTIMIZE    => '-O2 -pipe', ##-- optimization flags
   OBJECT       => 'Gfsm.o GfsmPerl.o',

   ##-- install these
   EXE_FILES => [glob("bin/*.perl")],

   ##-- DEBUG
   #MAKEAPERL=>1,
   #LINKTYPE=>'static',
   #MAP_TARGET=>'gfsmperl',
   #CCFLAGS=>'-g',
   ##-- /DEBUG

   ##-- stuff that probably doesn't need to be changed
   #XSOPT        => '-C++',
   TYPEMAPS     => ['perlobject.map', 'typemap'],
  );


#-----------------------------------------------------------------------
# Extensions
#-----------------------------------------------------------------------
##...

sub MY::depend {
  package MY;
  my $inherited = shift->SUPER::depend(@_);
  $inherited .= (
		 "\n\n"
		 ##-- included xs dependencies
		 ."Gfsm.c: "
		 .(''
		   ." Gfsm.xs"
		   ." Constants.xs"
		   ." Semiring.xs"
		   ." Alphabet.xs"
		   ." Automaton.xs"
		   ." Algebra.xs"
		   ." Arith.xs"
		   ." ArcIter.xs"
		   ." Lookup.xs"
		   ." Paths.xs"
		   ." Trie.xs"
		   ." Indexed.xs"
		   ." StateSort.xs"
		  )
		 ."\n\n"
		 ##-- c->o dependencies
		 ."Gfsm.o: Gfsm.c GfsmPerl.h\n"
		 ."\n"
		 ."GfsmPerl.o: GfsmPerl.h GfsmPerl.c\n"
		 ."\n"
		 ## -- more here
		 ."\n"
		);
  $inherited;
}

