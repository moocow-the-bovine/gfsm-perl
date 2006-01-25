#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <gfsm.h>

/*======================================================================
 * Memory Stuff
 */
extern GMemVTable gfsm_perl_vtable;

gpointer gfsm_perl_malloc(gsize n_bytes);
gpointer gfsm_perl_realloc(gpointer mem, gsize n_bytes);
void gfsm_perl_free(gpointer mem);

AV *gfsm_perl_paths_to_av(gfsmSet *paths_s);
HV *gfsm_perl_path_to_hv(gfsmPath *path);
AV *gfsm_perl_ptr_array_to_av_uv(GPtrArray *ary);

/*======================================================================
 * I/O: structs
 */
//-- struct for gfsm I/O to a perl scalar
typedef struct {
  SV     *sv; //-- scalar being written to
  size_t pos; //-- read position
} gfsmPerlSVHandle;

/*----------------------------------------------------------------------
 * I/O: Methods: SV*
 */
gfsmIOHandle *gfsmperl_io_new_sv(SV *sv, size_t pos);
void gfsmperl_io_free_sv(gfsmIOHandle *ioh);

gboolean gfsmperl_eof_sv(gfsmPerlSVHandle *svh);
gboolean gfsmperl_read_sv(gfsmPerlSVHandle *svh, void *buf, size_t nbytes);
gboolean gfsmperl_write_sv(gfsmPerlSVHandle *svh, const void *buf, size_t nbytes);
