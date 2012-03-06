#/*-*- Mode: C -*- */

MODULE = Gfsm		PACKAGE = Gfsm::Automaton           PREFIX = gfsm_

##=====================================================================
## Constructors etc.
##=====================================================================

##-- disable perl prototypes
PROTOTYPES: DISABLE

void gfsm_statesort_aff(gfsmAutomaton *fsm)
CODE:
  gfsm_statesort_aff(fsm,NULL);

void gfsm_statesort_dfs(gfsmAutomaton *fsm)
CODE:
  gfsm_statesort_dfs(fsm,NULL);

void gfsm_statesort_bfs(gfsmAutomaton *fsm)
CODE:
  gfsm_statesort_bfs(fsm,NULL);
