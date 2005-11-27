/*-*- Mode: C -*- */
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <gfsm.h>
#include "GfsmPerl.h"

MODULE = Gfsm		PACKAGE = Gfsm

##=====================================================================
## Gfsm (bootstrap)
##=====================================================================
BOOT:
 {
   g_mem_set_vtable(&gfsm_perl_vtable);
   //gfsm_allocators_enable();
 } 

##=====================================================================
## Debug
##=====================================================================
AV *
newav()
CODE:
 RETVAL=newAV();
 sv_2mortal((SV*)RETVAL);
OUTPUT:
 RETVAL

##-- input=ok
gfsmLabelVector *
labvec(gfsmLabelVector *vec)
CODE:
 //
OUTPUT:
 vec
CLEANUP:
 g_ptr_array_free(vec,TRUE);

##=====================================================================
## Gfsm (Constants)
##=====================================================================
INCLUDE: Constants.xs

##=====================================================================
## Gfsm::Semiring
##=====================================================================
INCLUDE: Semiring.xs

##=====================================================================
## Gfsm::Alphabet
##=====================================================================
INCLUDE: Alphabet.xs

##=====================================================================
## Gfsm::Automaton
##=====================================================================
INCLUDE: Automaton.xs
INCLUDE: ArcIter.xs
INCLUDE: Algebra.xs
INCLUDE: Lookup.xs
INCLUDE: Paths.xs
