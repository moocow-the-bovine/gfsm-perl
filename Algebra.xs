#/*-*- Mode: C -*- */

MODULE = Gfsm		PACKAGE = Gfsm::Automaton           PREFIX = gfsm_automaton

##=====================================================================
## Automata: Algebra
##=====================================================================

##-- disable perl prototypes
PROTOTYPES: DISABLE

#/** Compute transitive (@is_plus!=FALSE) or reflexive+transitive (@is_plus==FALSE)
# *  closure of @fsm.
# *  Destructively alters @fsm1.
# */
void
gfsm_automaton_closure(gfsmAutomaton *fsm, gboolean is_plus=FALSE)

#/** Compute @n ary closure of @fsm.
# *  \returns @fsm
# */
void
gfsm_automaton_n_closure(gfsmAutomaton *fsm, guint n)


#//------------------------------

#/**
# * Compute the complement of @fsm with respect to its own alphabet (alph==NULL),
# * or wrt. alph!=NULL, which should contain all of the lower-labels from @fsm.
# * Destructively alters @fsm.
# * \returns @fsm
# */
void
gfsm_automaton_complement(gfsmAutomaton *fsm, gfsmAlphabet *alph=NULL)
CODE:
 if (alph) { gfsm_automaton_complement_full(fsm,alph); }
 else      { gfsm_automaton_complement(fsm); }


#//------------------------------

#/** Compute the composition of transducer @fsm1 with @fsm2. \returns altered @fsm1 */
#/// TODO
#gfsmAutomaton * gfsm_automaton_compose(gfsmAutomaton *fsm1, gfsmAutomaton *fsm2)

#/** Append @fsm2 onto the end of @fsm1 @n times.  \returns @fsm1 */
void
gfsm_automaton_concat(gfsmAutomaton *fsm1, gfsmAutomaton *fsm2, guint n=1)
CODE:
 gfsm_automaton_n_concat(fsm1,fsm2,n);


#//------------------------------
#/** Determinise @fsm1 pseudo-destructively.
# *  \note weights on epsilon-arcs are probably not handled correctly.
# *  \returns altered @fsm1
# */
void
gfsm_automaton_determinize(gfsmAutomaton *fsm)

#//------------------------------
#/** Remove language of @fsm2 from @fsm1. \returns @fsm1 */
#/// TODO
#gfsmAutomaton *gfsm_automaton_difference(gfsmAutomaton *fsm1, gfsmAutomaton *fsm2);


#//------------------------------
#/** Compute the intersection of two acceptors @fsm1 and @fsm2. */
#/// TODO
#gfsmAutomaton *gfsm_automaton_intersection(gfsmAutomaton *fsm1, gfsmAutomaton *fsm2);

#//------------------------------
#/** Invert upper and lower labels of an FSM */
void
gfsm_automaton_invert(gfsmAutomaton *fsm)

#//------------------------------
#/** Compute Cartesian product of @fsm1 and @fsm2.  \returns @fsm1  */
#/// TODO
#gfsmAutomaton *gfsm_automaton_product(gfsmAutomaton *fsm1, gfsmAutomaton *fsm2);


#//------------------------------
#/** Project one "side" (lower or upper) of @fsm */
void
gfsm_automaton_project(gfsmAutomaton *fsm, gfsmLabelSide which)

#//------------------------------
#/** Prune unreachable states from @fsm.  \returns @fsm */
void
gfsm_automaton_prune(gfsmAutomaton *fsm)

#//------------------------------
#/** Reverse an @fsm. \returns @fsm */
void
gfsm_automaton_reverse(gfsmAutomaton *fsm)

#//------------------------------
#/** Remove epsilon arcs from @fsm.  \returns @fsm */
#/// TODO
#gfsmAutomaton *gfsm_automaton_rmepsilon(gfsmAutomaton *fsm)

#//------------------------------
#/** Assign the union of @fsm1 and @fsm2 to @fsm1. \returns @fsm1 */
void
gfsm_automaton_union(gfsmAutomaton *fsm1, gfsmAutomaton *fsm2)


