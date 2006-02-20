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
gfsm_trie_add_paths(gfsmTrie *trie, gfsmLabelVector *lo, gfsmLabelVector *hi, gfsmWeight w=0, gboolean add_to_arcs=TRUE, gboolean add_to_state_final=FALSE, gboolean add_to_path_final=TRUE)
CODE:
 RETVAL = gfsm_trie_add_paths_full(trie, lo, hi, w, add_to_arcs, add_to_state_final, add_to_path_final);
OUTPUT:
 RETVAL
CLEANUP:
 if (lo) g_ptr_array_free(lo,TRUE);
 if (hi) g_ptr_array_free(hi,TRUE);


##--------------------------------------------------------------
## Methods: find prefix
void
gfsm_trie_find_prefixes(gfsmTrie *trie, gfsmLabelVector *lo, gfsmLabelVector *hi)
PREINIT:
 gfsmStateId qid;
 guint lo_i;
 guint hi_i;
 gfsmWeight w_last;
PPCODE:
{
  qid = gfsm_trie_find_prefix(trie, lo,hi, &lo_i,&hi_i,&w_last);
  //
  //-- cleanup
  if (lo) g_ptr_array_free(lo,TRUE);
  if (hi) g_ptr_array_free(hi,TRUE);
  //
  //-- return stack
  ST(0) = newSVuv(qid);
  sv_2mortal(ST(0));
  if (GIMME_V != G_ARRAY) {
    XSRETURN(1);
  }
  /* (GIMME_V == G_ARRAY) */
  ST(1) = newSVuv(lo_i);
  ST(2) = newSVuv(hi_i);
  ST(3) = newSVnv(w_last);
  sv_2mortal(ST(1));
  sv_2mortal(ST(2));
  sv_2mortal(ST(3));
  XSRETURN(4);
}


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
