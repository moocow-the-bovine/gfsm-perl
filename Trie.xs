#/*-*- Mode: C -*- */

MODULE = Gfsm		PACKAGE = Gfsm::Automaton           PREFIX = gfsm_trie_

##=====================================================================
## Constructors etc.
##=====================================================================

##-- disable perl prototypes
PROTOTYPES: DISABLE

##--------------------------------------------------------------
## Constructor: new()
gfsmTrie*
newTrie(char *CLASS, gboolean is_transducer=1, gfsmSRType srtype=gfsmTrieDefaultSRType, guint size=gfsmAutomatonDefaultSize)
PREINIT:
 gfsmAutomatonFlags flags = gfsmTrieDefaultFlags;
CODE:
 flags.is_transducer = is_transducer;
 RETVAL = gfsm_automaton_new_full(flags, srtype, size);
OUTPUT:
 RETVAL

##--------------------------------------------------------------
## Methods: add paths
gfsmStateId
gfsm_trie_add_paths(gfsmTrie *trie, gfsmLabelVector *lo, gfsmLabelVector *hi=NULL, gfsmWeight w=0, gboolean add_to_arcs=TRUE, gboolean add_to_state_final=TRUE, gboolean add_to_path_final=TRUE)
CODE:
 RETVAL = gfsm_trie_add_paths_full(trie, lo, hi, w, add_to_arcs, add_to_state_final, add_to_path_final);
OUTPUT:
 RETVAL

##--------------------------------------------------------------
## Methods: find arcs
gfsmStateId
gfsm_trie_find_arc_lower(gfsmTrie *trie, gfsmStateId qid, gfsmLabelVal lab)
PREINIT:
 gfsmArc *a;
CODE:
 a=gfsm_trie_find_arc_lower(trie,qid,lab);
 if (a) RETVAL=a->target;
 else   RETVAL=gfsmNoState;
OUTPUT:
 RETVAL

gfsmStateId
gfsm_trie_find_arc_upper(gfsmTrie *trie, gfsmStateId qid, gfsmLabelVal lab)
PREINIT:
 gfsmArc *a;
CODE:
 a=gfsm_trie_find_arc_upper(trie,qid,lab);
 if (a) RETVAL=a->target;
 else   RETVAL=gfsmNoState;
OUTPUT:
 RETVAL


##--------------------------------------------------------------
## Methods: find or insert arcs
gfsmStateId
gfsm_trie_get_arc_lower(gfsmTrie *trie, gfsmStateId qid, gfsmLabelVal lab, gfsmWeight w, gboolean add_weight=TRUE)

gfsmStateId
gfsm_trie_get_arc_upper(gfsmTrie *trie, gfsmStateId qid, gfsmLabelVal lab, gfsmWeight w, gboolean add_weight=TRUE)
