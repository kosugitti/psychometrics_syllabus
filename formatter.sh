#!/usr/bin/bash
set -euo pipefail

for f in *.tex ; do
    echo $f
    latexindent $f -w
done
