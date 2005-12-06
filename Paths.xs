#/*-*- Mode: C -*- */

MODULE = Gfsm		PACKAGE = Gfsm::Automaton           PREFIX = gfsm_automaton_

##=====================================================================
## Constructors etc.
##=====================================================================

##-- disable perl prototypes
PROTOTYPES: DISABLE

##--------------------------------------------------------------
## automaton paths (hash-refs)

AV *
paths_full(gfsmAutomaton *fsm, gfsmLabelSide which)
PREINIT:
 gfsmSet   *paths_s=NULL;
CODE:
 paths_s = gfsm_automaton_paths_full(fsm,NULL,which);
 RETVAL  = gfsm_perl_paths_to_av(paths_s);
 //
 gfsm_set_free(paths_s);
 sv_2mortal((SV*)RETVAL);
 //
OUTPUT:
 RETVAL


##-- ALLOCATION PROBLEMS -- NEW MEMORY ALLOCATOR ?
AV *
paths_old(gfsmAutomaton *fsm, gfsmLabelSide which)
PREINIT:
 gfsmSet   *paths_s=NULL;
 GPtrArray *paths_a=NULL;
 int i,j;
 AV *labs=NULL;
CODE:
 paths_s=gfsm_automaton_paths_full(fsm,NULL,which);
 paths_a=g_ptr_array_sized_new(gfsm_set_size(paths_s));
 gfsm_set_to_ptr_array(paths_s, paths_a);
 RETVAL = newAV();
 sv_2mortal((SV*)RETVAL);
 //
 for (i=0; i<paths_a->len; i++) {
   gfsmPath *path = (gfsmPath*)g_ptr_array_index(paths_a,i);
   HV       *hv   = newHV();
   SV       *hvr  = newRV((SV*)hv);
   sv_2mortal((SV*)hv);
   sv_2mortal((SV*)hvr);
   //
   //-- lower
   labs = newAV();
   sv_2mortal((SV*)labs);
   for (j=0; j < path->lo->len; j++) {
     av_push(labs, newSVuv((UV)g_ptr_array_index(path->lo,j)));
   }
   hv_store(hv, "lo", 2, newRV((SV*)labs), 0);
   //
   //-- upper
   labs = newAV();
   sv_2mortal((SV*)labs);
   for (j=0; j < path->lo->len; j++) {
     av_push(labs, newSVuv((UV)g_ptr_array_index(path->hi,j)));
   }
   hv_store(hv, "hi", 2, newRV((SV*)labs), 0);

   //-- weight
   hv_store(hv, "w", 1, newSVnv(path->w), 0);
   //
   //-- path
   av_push(RETVAL, newRV((SV*)hv));
 }
 //
 gfsm_set_free(paths_s);
 g_ptr_array_free(paths_a,TRUE);
 //
OUTPUT:
 RETVAL
