#!/bin/sh

if [ $# -eq 0 ] ; then
  echo "Usage: $0 OPNAME [BASENAME [ARGS]]"
  exit 1
fi

op="$1"
shift
if [ $# -gt 0 ] ; then
    base="$1"
    shift;
else
    base="$op";
fi

cmd="gfsmcompile '${base}-in.tfst' | gfsm${op} $@ | gfsmprint > '${base}-out.tfst'"
echo $cmd
eval $cmd
