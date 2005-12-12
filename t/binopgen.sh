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

cmd="
  gfsmcompile '${base}-in-1.tfst' -F '${base}-in-1.gfst';
  gfsmcompile '${base}-in-2.tfst' -F '${base}-in-2.gfst';
  gfsm${op} $@ '${base}-in-1.gfst' '${base}-in-2.gfst' | gfsmprint > '${base}-out.tfst';
  rm -f '${base}-in-[12].gfst';
"
echo $cmd
eval $cmd
