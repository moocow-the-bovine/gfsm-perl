#!/bin/bash

./gfsm-random-trie.perl -noeps "$@" -F tmp1.gfst
./gfsm-random-trie.perl -noeps "$@" -F tmp2.gfst
#gfsminvert tmp1.gfst -F tmp2.gfst

gfsmcompose tmp1.gfst tmp2.gfst | gfsmconnect | gfsmrenumber -F out.gfst
gfsminfo out.gfst
