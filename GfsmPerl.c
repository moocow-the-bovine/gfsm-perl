#include "GfsmPerl.h"

GMemVTable gfsm_perl_vtable =
  {
    gfsm_perl_malloc,
    gfsm_perl_realloc,
    gfsm_perl_free,
    NULL,
    NULL,
    NULL
  };

gpointer gfsm_perl_malloc(gsize n_bytes)
{
  gpointer ptr=NULL;
  Newc(0, ptr, n_bytes, char, gpointer);
  return ptr;
}

gpointer gfsm_perl_realloc(gpointer mem, gsize n_bytes)
{
  Renewc(mem, n_bytes, char, gpointer);
  return mem;
}

void gfsm_perl_free(gpointer mem)
{
  Safefree(mem);
}

AV *gfsm_perl_paths_to_av(gfsmSet *paths_s)
{
  int i;
  AV *RETVAL = newAV();
  GPtrArray *paths_a=g_ptr_array_sized_new(gfsm_set_size(paths_s));
  
  sv_2mortal((SV*)RETVAL);
  for (i=0; i < paths_a->len; i++) {
    gfsmPath *path = (gfsmPath*)g_ptr_array_index(paths_a,i);
    HV       *hv   = gfsm_perl_path_to_hv(path);
    av_push(RETVAL, newRV((SV*)hv));
  }
  g_ptr_array_free(paths_a,TRUE);
  return RETVAL;
}

HV *gfsm_perl_path_to_hv(gfsmPath *path)
{
  HV *hv = newHV();
  AV *lo = gfsm_perl_ptr_array_to_av_uv(path->lo);
  AV *hi = gfsm_perl_ptr_array_to_av_uv(path->hi);

  hv_store(hv, "lo", 2, newRV((SV*)lo), 0);
  hv_store(hv, "hi", 2, newRV((SV*)hi), 0);
  hv_store(hv, "w",  1, newSVnv(path->w), 0);
  sv_2mortal((SV*)hv);

  return hv;
}

AV *gfsm_perl_ptr_array_to_av_uv(GPtrArray *ary)
{
  AV *av = newAV();
  guint i;
  sv_2mortal((SV*)av);
  for (i=0; i < ary->len; i++) {
    av_push(av, newSVuv((UV)g_ptr_array_index(ary,i)));
  }
  return av;
}
