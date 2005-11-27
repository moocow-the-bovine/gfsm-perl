#/*-*- Mode: C -*- */

MODULE = Gfsm		PACKAGE = Gfsm::Automaton         PREFIX = gfsm_automaton

##=====================================================================
## Constructors etc.
##=====================================================================

##-- disable perl prototypes
PROTOTYPES: DISABLE

##--------------------------------------------------------------
## linear lookup
void
gfsm_automaton_lookup(gfsmAutomaton *fst, gfsmLabelVector *input, gfsmAutomaton *result)
CLEANUP:
 g_ptr_array_free(input,TRUE);
