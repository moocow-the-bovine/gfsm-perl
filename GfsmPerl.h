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
 * gfsmPerlAlphabet: alphabet of scalars
 */

typedef struct {
  gfsmUserAlphabet a; //-- underlying alphabet
  HV *hv; //-- maps keys->labels
  AV *av; //-- maps labels->keys
} gfsmPerlAlphabet;

/*--------------------------------------------------------------
 * gfsmPerlAlphabet: constructors etc.
 */
gfsmAlphabet *gfsm_perl_alphabet_new(void);

void gfsm_perl_alphabet_free(gfsmPerlAlphabet *alph);

/*--------------------------------------------------------------
 * gfsmPerlAlphabet: user methods
 */

//-- key_lookup: key->label lookup function
gfsmLabelVal gfsm_perl_alphabet_key_lookup(gfsmPerlAlphabet *alph, SV* key);

//-- lab_lookup: label->key lookup function
SV* gfsm_perl_alphabet_label_lookup(gfsmPerlAlphabet *alph, gfsmLabelVal lab);

//-- insert: insertion function: receives a newly copied key!
gfsmLabelVal gfsm_perl_alphabet_insert(gfsmPerlAlphabet *alph, SV *key, gfsmLabelVal lab);

//-- lab_remove: label removal function
void gfsm_perl_alphabet_remove(gfsmPerlAlphabet *alph, gfsmLabelVal lab);

//-- string read function for perl scalars
SV *gfsm_perl_alphabet_scalar_read(gfsmPerlAlphabet *alph, GString *gstr);

//-- string write function for perl scalars
void gfsm_perl_alphabet_scalar_write(gfsmPerlAlphabet *alph, SV *sv, GString *gstr);

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
