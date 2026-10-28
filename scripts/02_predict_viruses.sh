#!/usr/bin/env bash

mkdir -p output

# VirSorter2
virsorter run -w output/virsorter -i input/contigs_5kb.fna -j 60 --min-length 5000 --min-score 0.5 --include-groups dsDNAphage,NCLDV,RNA,ssDNA,lavidaviridae -d database/virsorter

# VIBRANT
VIBRANT_run.py -i input/contigs_5kb.fna -t 8 -l 5000 -folder output

# DeepVirFinder
python software/DeepVirFinder/dvf.py -i input/contigs_5kb.fna -o output/deepvirfinder -l 5000 -c 8 &> output/deepvirfinder.log

# VirFinder
Rscript -e '
library(VirFinder)
predResult <- VF.pred("input/contigs_5kb.fna")
predResult$qvalue <- VF.qvalue(predResult$pvalue)
predResult_sorter <- predResult[order(predResult$qvalue), ]
write.table(predResult_sorter, file="output/virfinder.txt", quote=FALSE, sep="\t")
'

# geNomad
genomad end-to-end --min-score 0.8 --threads 4 --cleanup input/contigs_5kb.fna output/genomad database/genomad
