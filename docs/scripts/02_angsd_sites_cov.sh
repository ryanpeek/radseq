#!/bin/bash -l

#SBATCH -o slurm_outs/02_angsd_sites_cov-%j.out
#OUTDIR=/home/rapeek/projects/rana_rapture/fastq/angsd_output
#SBATCH -J angsd_sites_covs

bamlist=$1
out=$2

nInd=$(wc $bamlist | awk '{print $1}')
minInd=1 #$[$nInd/2]

angsd -bam $bamlist -out $out -minQ 20 -minMapQ 10 -minInd $minInd -GL 1 -doMajorMinor 1 -doMaf 2 -doPost 2 -doGeno 4 -postCutoff 0.95 -sites bait_snp_filt

