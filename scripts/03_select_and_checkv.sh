#!/usr/bin/env bash

# Select candidate viruses
mkdir -p output
grep -v 'seqname' output/virsorter/final-viral-score.tsv | sed 's/||.*$//' > output/virsorter_ids.txt
sed 's/_fragment.*$//' output/VIBRANT_contigs_5kb/VIBRANT_phages_contigs_5kb/contigs_5kb.phages_combined.txt > output/vibrant_ids.txt
awk '$4>=0.9 && $5<0.05' output/virfinder.txt | cut -f2 > output/virfinder_ids.txt
awk '$3>=0.9 && $4<0.05' output/deepvirfinder/contigs_5kb.fna_gt5000bp_dvfpred.txt | cut -f1 > output/deepvirfinder_ids.txt
grep -v 'seq_name' output/genomad/contigs_5kb_summary/contigs_5kb_virus_summary.tsv | cut -f1 > output/genomad_ids.txt
cat output/virsorter_ids.txt output/vibrant_ids.txt output/virfinder_ids.txt output/deepvirfinder_ids.txt output/genomad_ids.txt | sort -u > output/candidate_ids.txt
seqkit grep -n -f output/candidate_ids.txt input/contigs_5kb.fna -o output/candidates.fna

# CheckV
checkv end_to_end output/candidates.fna output/checkv -t 16 -d database/checkv
cat output/checkv/proviruses.fna output/checkv/viruses.fna | sed -e 's/ .*$//' -e 's/_1$//' > output/checkv_sequences.fna
checkv end_to_end output/checkv_sequences.fna output/checkv_rerun -t 16 -d database/checkv
awk '$6==0 && $7>0' output/checkv_rerun/quality_summary.tsv | cut -f1 > output/discarded_ids.txt
seqkit grep -n -v -f output/discarded_ids.txt output/checkv_sequences.fna -o output/viruses.fna
seqkit seq -m 5000 output/viruses.fna > output/viruses_5kb.fna
