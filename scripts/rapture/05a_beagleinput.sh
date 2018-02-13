#!/bin/bash -l

#SBATCH -o slurm_outs/05a_beagle-%j.out
#SBATCH -J make_beagle


bamlist=$1
out=$2
minInd_cutoff_ratio=$3 # i.e., 0.8, 0.9, etc

nInd=$(wc $bamlist | awk '{print $1}')

minInd=$(echo "$nInd*$minInd_cutoff_ratio" | bc)

angsd -bam $bamlist -out $out -nThreads 10 -minQ 20 -minMapQ 10 -minInd $minInd -GL 1 -doMajorMinor 1 -doMaf 1 -SNP_pval 1e-6 -minMaf 0.05 -doGlf 2 






