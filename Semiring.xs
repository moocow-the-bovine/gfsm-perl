#/*-*- Mode: C -*- */

MODULE = Gfsm		PACKAGE = Gfsm::Semiring

##=====================================================================
## Constructors etc.
##=====================================================================

##-- disable perl prototypes
PROTOTYPES: DISABLE

##--------------------------------------------------------------
## Constructor: new()
gfsmSemiring*
new(char *CLASS, gfsmSRType type=gfsmSRTTropical)
CODE:
 RETVAL=gfsm_semiring_new(type);
OUTPUT:
 RETVAL

##--------------------------------------------------------------
## Copy constructor
gfsmSemiring*
copy(gfsmSemiring* sr)
INIT:
   char *CLASS=HvNAME(SvSTASH(SvRV(ST(0))));  // needed by typemap
CODE:
 RETVAL=gfsm_semiring_copy(sr);
OUTPUT:
 RETVAL

##--------------------------------------------------------------
## Destructor: DESTROY()
void
DESTROY(gfsmSemiring* sr)
CODE:
 gfsm_semiring_free(sr);


##=====================================================================
## General Access
##=====================================================================

##--------------------------------------------------------------
## Semiring constants

gfsmSRType
type(gfsmSemiring *sr)
CODE:
 RETVAL=sr->type;
OUTPUT:
 RETVAL

const char *
name(gfsmSemiring *sr)
CODE:
 RETVAL = gfsm_sr_type_to_name(sr->type);
OUTPUT:
 RETVAL

gfsmWeight
zero(gfsmSemiring *sr)
CODE:
 RETVAL=sr->zero;
OUTPUT:
 RETVAL

gfsmWeight
one(gfsmSemiring *sr)
CODE:
 RETVAL=sr->one;
OUTPUT:
 RETVAL

##--------------------------------------------------------------
## Predicates & Comparison

gboolean
equal(gfsmSemiring *sr, gfsmWeight w1, gfsmWeight w2)
CODE:
 RETVAL=gfsm_sr_equal(sr,w1,w2);
OUTPUT:
 RETVAL

gboolean
less(gfsmSemiring *sr, gfsmWeight w1, gfsmWeight w2)
CODE:
 RETVAL=gfsm_sr_less(sr,w1,w2);
OUTPUT:
 RETVAL

int
compare(gfsmSemiring *sr, gfsmWeight w1, gfsmWeight w2)
CODE:
 RETVAL=gfsm_sr_compare(sr,w1,w2);
OUTPUT:
 RETVAL


##--------------------------------------------------------------
## Semiring operations

gfsmWeight
plus(gfsmSemiring *sr, gfsmWeight w1, gfsmWeight w2)
CODE:
 RETVAL=gfsm_sr_plus(sr,w1,w2);
OUTPUT:
 RETVAL

gfsmWeight
times(gfsmSemiring *sr, gfsmWeight w1, gfsmWeight w2)
CODE:
 RETVAL=gfsm_sr_times(sr,w1,w2);
OUTPUT:
 RETVAL


##--------------------------------------------------------------
## Utilities
gfsmWeight
gfsm_log_add(gfsmWeight x, gfsmWeight y)
