#!/bin/bash -l

#SBATCH -o slurm_outs/02a_angsd_unfilt_all-%j.out
#SBATCH --mem 16G
#OUTDIR=/home/rapeek/projects/rana_rapture/MERGED/angsd_output
#SBATCH -J unfiltered_all_sites

echo "Starting Job: "
date

bamlist=$1
out=$2

#nInd=$(wc $bamlist | awk '{print $1}')

#minInd=$[$nInd/2] # remove this from the next line so ALL SNPs from all individuals get picked up (not just half)

angsd -bam $bamlist -out $out -minQ 20 -minMapQ 10 -minInd 1 -GL 1 -doMajorMinor 1 -doMaf 2 -SNP_pval 1

echo "Ending Job: "
date
