#!/bin/sh

#SBATCH -o slurm_outs/02_get_geno_cov-%j.out
#SBATCH -J get_geno_cov

echo "Starting Job: "
date

bamlist=$1
out=$2

nInd=$(wc $bamlist | awk '{print $1}')
minInd=$[$nInd/2]
outdir='coverage'

angsd -bam $bamlist -GL 1 -out ${outdir}/${out} -doMaf 2 -minInd $minInd -doMajorMinor 1 -doGeno 4 -doPost 2 -postCutoff 0.95 -minMaf 0.05 -SNP_pval 1e-6 -doCounts 1 -dumpCounts 1

gunzip ${outdir}/${out}.*.gz

echo "Ending Job: "
date
