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
   ;
 } 

##=====================================================================
## Gfsm (Debug)
##=====================================================================

#ifdef GFSMDEBUG

int __refcnt(SV *sv)
CODE:
 if (sv && SvOK(sv)) {
   RETVAL = SvREFCNT(sv);
 } else {
   XSRETURN_UNDEF;
 }
OUTPUT:
 RETVAL

#endif


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
INCLUDE: Arith.xs
INCLUDE: Lookup.xs
INCLUDE: Paths.xs
INCLUDE: Trie.xs

##=====================================================================
## Gfsm::Automaton::Indexed
##=====================================================================
INCLUDE: Indexed.xs
