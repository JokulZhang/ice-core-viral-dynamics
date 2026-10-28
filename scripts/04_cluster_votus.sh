#!/usr/bin/env bash

# Cluster vOTUs
makeblastdb -in output/viruses_5kb.fna -dbtype nucl -out output/virus_db
blastn -query output/viruses_5kb.fna -db output/virus_db -outfmt '6 std qlen slen' -max_target_seqs 10000 -out output/blast.tsv -num_threads 16
python software/anicalc.py -i output/blast.tsv -o output/ani.tsv
python software/aniclust.py --fna output/viruses_5kb.fna --ani output/ani.tsv --out output/clusters.tsv --min_ani 95 --min_tcov 85 --min_qcov 85
