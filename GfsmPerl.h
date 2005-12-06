#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <gfsm.h>

extern GMemVTable gfsm_perl_vtable;

gpointer gfsm_perl_malloc(gsize n_bytes);
gpointer gfsm_perl_realloc(gpointer mem, gsize n_bytes);
void gfsm_perl_free(gpointer mem);

AV *gfsm_perl_paths_to_av(gfsmSet *paths_s);
HV *gfsm_perl_path_to_hv(gfsmPath *path);
AV *gfsm_perl_ptr_array_to_av_uv(GPtrArray *ary);
