#!/bin/bash -l

#SBATCH -o slurm_outs/04_pca_pdf-%j.out
#OUTDIR=pca_pdfs
#SBATCH -J PCA_plots

echo "Starting Job: "
date

out=$1
bamclst=$2

outdir='pca_pdfs'
homedir='/home/rapeek/projects/rana_rapture/fastq'

Rscript --vanilla --slave  ${homedir}/pca_makeplot.R -i ./angsd_output/${out}.covar -c 1-2 -a ${homedir}/${bamclst} -o ${outdir}/${out}_12_pca.pdf
Rscript --vanilla --slave ${homedir}/pca_makeplot.R -i ./angsd_output/${out}.covar -c 1-3 -a ${homedir}/${bamclst} -o ${outdir}/${out}_13_pca.pdf
Rscript --vanilla --slave ${homedir}/pca_makeplot.R -i ./angsd_output/${out}.covar -c 2-3 -a ${homedir}/${bamclst} -o ${outdir}/${out}_23_pca.pdf

echo "Ending Job: "
date
