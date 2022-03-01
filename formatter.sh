#!/usr/bin/bash

for f in *.tex ; do
    echo $f
    latexindent $f -w
done
