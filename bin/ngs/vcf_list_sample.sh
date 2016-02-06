#!/bin/bash

# Check if bcftools exists
command -v bcftools >/dev/null &2>1 || { echo >&2 "BCFTOOLS not found in path.";exit 1; }
[ $# -ge 1 -a -f "$1" ] && input="$1" || input="-"
cat $input | bcftools view -h | grep "^#CHR" | cut -f 10- | tr "\t" "\n"
