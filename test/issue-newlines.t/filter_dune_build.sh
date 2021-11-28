#!/bin/bash

# breakdown:
#   filter [@@@ocaml.ppx.context whitespace {  0-or-more not-close-brace-chars }]
#   and normalize file system paths
dune build $@ 2>&1 | \
    sed  -E 'H;1h;$!d;x;s/\[@@@ocaml\.ppx\.context\s+\{[^}]*\}\]//g' | \
    sed 's/home[^ ]*bin\//home\/...\/bin\//'