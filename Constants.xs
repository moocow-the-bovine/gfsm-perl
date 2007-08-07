#/*-*- Mode: C -*- */

MODULE = Gfsm		PACKAGE = Gfsm

##=====================================================================
## Constants
##=====================================================================

##-- disable perl prototypes
PROTOTYPES: DISABLE

##--------------------------------------------------------------
## gfsmVersion.h
const char *
library_version()
 CODE:
   RETVAL=gfsm_version_string;
 OUTPUT:
   RETVAL

##--------------------------------------------------------------
## gfsmCommon.h
gfsmLabelId
epsilon()
 CODE:
   RETVAL=gfsmEpsilon;
 OUTPUT:
   RETVAL

gfsmLabelId
epsilon1()
 CODE:
   RETVAL=gfsmEpsilon1;
 OUTPUT:
   RETVAL

gfsmLabelId
epsilon2()
 CODE:
   RETVAL=gfsmEpsilon2;
 OUTPUT:
   RETVAL

gfsmLabelId
noLabel()
 CODE:
   RETVAL=gfsmNoLabel;
 OUTPUT:
   RETVAL

gfsmStateId
noState()
 CODE:
   RETVAL=gfsmNoState;
 OUTPUT:
   RETVAL

##--------------------------------------------------------------
## Semiring types
gfsmSRType
SRTUnknown()
 CODE:
   RETVAL=gfsmSRTUnknown;
 OUTPUT:
  RETVAL

gfsmSRType
SRTBoolean()
 CODE:
   RETVAL=gfsmSRTBoolean;
 OUTPUT:
  RETVAL

gfsmSRType
SRTLog()
 CODE:
   RETVAL=gfsmSRTLog;
 OUTPUT:
  RETVAL

gfsmSRType
SRTReal()
 CODE:
   RETVAL=gfsmSRTReal;
 OUTPUT:
  RETVAL

gfsmSRType
SRTTrivial()
 CODE:
   RETVAL=gfsmSRTTrivial;
 OUTPUT:
  RETVAL

gfsmSRType
SRTTropical()
 CODE:
   RETVAL=gfsmSRTTropical;
 OUTPUT:
  RETVAL

gfsmSRType
SRTPLog()
 CODE:
   RETVAL=gfsmSRTPLog;
 OUTPUT:
  RETVAL

gfsmSRType
SRTUser()
 CODE:
   RETVAL=gfsmSRTUser;
 OUTPUT:
  RETVAL


##--------------------------------------------------------------
## gfsmArc.h: Automaton sort modes
gfsmArcSortMode
ASMNone()
CODE:
 RETVAL=gfsmASMNone;
OUTPUT:
 RETVAL

gfsmArcSortMode
ASMLower()
CODE:
 RETVAL=gfsmASMLower;
OUTPUT:
 RETVAL

gfsmArcSortMode
ASMUpper()
CODE:
 RETVAL=gfsmASMUpper;
OUTPUT:
 RETVAL

gfsmArcSortMode
ASMWeight()
CODE:
 RETVAL=gfsmASMWeight;
OUTPUT:
 RETVAL

##--------------------------------------------------------------
## gfsmArc.h: label sides
gfsmLabelSide
LSBoth()
CODE:
 RETVAL=gfsmLSBoth;
OUTPUT:
 RETVAL

gfsmLabelSide
LSLower()
CODE:
 RETVAL=gfsmLSLower;
OUTPUT:
 RETVAL

gfsmLabelSide
LSUpper()
CODE:
 RETVAL=gfsmLSUpper;
OUTPUT:
 RETVAL
