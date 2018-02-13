#!/bin/bash -l

#SBATCH -o slurm_outs/03_pca_calc-%j.out
#SBATCH -J pca_calc_sites

echo "Starting Job: "
date

bamlist=$1
out=$2
bamdir=$3 

nInd=$(wc ${bamdir}/${bamlist} | awk '{print $1}')
minInd=$[$nInd/2]
outdir='angsd_output'

angsd -bam ${bamdir}/${bamlist} -out ${outdir}/${out} -minQ 20 -minMapQ 10 -minInd $minInd -GL 1 -doMajorMinor 1 -doMaf 2 -doPost 2 -doGeno 32 -minMaf 0.05 -postCutoff 0.95 -SNP_pval 1e-6 -sites bait_lengths.txt

gunzip ${outdir}/${out}.*.gz

count=$(sed 1d ${outdir}/${out}.mafs | wc -l | awk '{print $1}')

ngsCovar -probfile ${outdir}/${out}.geno -outfile ${outdir}/${out}.covar -nind $nInd -nsites $count -call 1

echo "Ending Job: "
date
