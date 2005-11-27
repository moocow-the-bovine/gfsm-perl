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
