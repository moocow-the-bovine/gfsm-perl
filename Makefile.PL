use ExtUtils::MakeMaker;

##----------------------------------------------------------------------
## Configuration
##----------------------------------------------------------------------
if (system("pkg-config --atleast-version=0.0.7 gfsm") != 0) {
  die("Requird module gfsm >= v0.0.7 not found!\n");
}

$GFSM_IFLAGS=`pkg-config --cflags-only-I gfsm`;
$GFSM_LDFLAGS=`pkg-config --libs-only-L gfsm`;
$GFSM_LIBS=`pkg-config --libs-only-l gfsm`;

##----------------------------------------------------------------------
## MAIN
##----------------------------------------------------------------------
WriteMakefile
  (
   NAME		=> 'Gfsm',
   DISTNAME	=> 'gfsm-perl',
   AUTHOR       => 'Bryan Jurish <moocow@ling.uni-potsdam.de>',
   ABSTRACT	=> 'Perl interface to libgfsm finite-state library',
   VERSION_FROM	=> 'Gfsm.pm',


   ##-- user variables
   #CC           => 'c++',   ##-- your c++ compiler
   LIBS         => "$GFSM_LDFLAGS $GFSM_LIBS",      ##-- additional libraries
   DEFINE       => '-DHAVE_CONFIG_H',     ##-- additional defines
   INC          => $GFSM_IFLAGS,      ##-- additional includes
   CCFLAGS      => '',      ##-- additional flags
   OBJECT       => 'Gfsm.o GfsmPerl.o',

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
		   ." ArcIter.xs"
		   ." Lookup.xs"
		   ." Paths.xs"
		   ." Trie.xs"
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

