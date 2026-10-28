#!/usr/bin/env bash

# Rename contigs
for file in input/*.fa; do
  name=$(basename "$file" .fa)
  sed -i -e "s/>\(k.*_.*\) flag.*$/>${name}x_\1/g" "$file"
done

# Select contigs of at least 5 kb
mkdir -p output
while read -r id; do
  seqkit seq -m 5000 -j 8 "input/${id}.contigs.fa" > "output/${id}.renamed_5kb.fna"
done < input/id.list
