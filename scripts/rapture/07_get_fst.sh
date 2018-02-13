#!/bin/bash

#SBATCH -o slurm_outs/07_get_fst-%j.out
#SBATCH -J getFst
#SBATCH --mem 16G

echo "Starting Job: "
date

SFSdir='/home/rapeek/projects/rana_rapture/MERGED/thetas'
outdir='/home/rapeek/projects/rana_rapture/MERGED/FST'
pop1=$1
pop2=$2

~/programs/angsd/misc/realSFS ${SFSdir}/${1}.saf.idx ${SFSdir}/${2}.saf.idx > ${SFSdir}/${1}.${2}.ml
~/programs/angsd/misc/realSFS fst index ${SFSdir}/${1}.saf.idx ${SFSdir}/${2}.saf.idx -sfs ${SFSdir}/${1}.${2}.ml -fstout ${SFSdir}/${1}.${2}.fstout
~/programs/angsd/misc/realSFS fst stats ${SFSdir}/${1}.${2}.fstout.fst.idx > ${outdir}/${1}.${2}.Fst.txt

echo "Ending Job: "
date

