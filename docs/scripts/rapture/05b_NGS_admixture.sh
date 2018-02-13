#!/bin/bash -l

#SBATCH -o slurm_outs/05b_admix-%j.out
#SBATCH -J admixture

input=$1
admixout=$2
K=$3

NGSadmix -likes $input -K $K -o $admixout -minMaf 0.05






