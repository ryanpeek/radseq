#!/bin/bash -l

#SBATCH -o slurm_outs/get_fa_length-%j.out
#SBATCH -J get_fa_length

echo "Starting Job: "
date

file=$1

wc=$(wc -l ${file} | awk '{print $1}')
x=1

echo "" > fasta_lengths.txt
while [ $x -le $wc ] 
do

	fa_id=$(sed -n ${x}p ${file} | sed "s/>R/R/g") #>> fasta_id.txt
	#sed -n ${x}p ${file} | sed "s/>R/R/g" >> fasta_id.txt
	x=$(( $x + 1 ))
	
	fa_l=$(sed -n ${x}p ${file} | wc -c) #  >> fasta_length.txt	
	#sed -n ${x}p ${file} | wc -c  >> fasta_length.txt 

	echo $fa_id $fa_l >> fasta_lengths.txt
	
	x=$(( $x + 1 ))
done

