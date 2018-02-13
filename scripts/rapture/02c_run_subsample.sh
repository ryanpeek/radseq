#!/bin/bash -l

#SBATCH -o slurm_outs/02c_subsample-%j.out
#SBATCH -J subsample

list=$1
num=$2

wc=$(wc -l ${list} | awk '{print $1}')

x=1
while [ $x -le $wc ] 
do
	string="sed -n ${x}p ${list}" 
	str=$($string)

	var=$(echo $str | awk -F"\t" '{print $1}')   
	set -- $var
	c1=$1

	count=$(samtools view -c ${c1}.bam)

        if [ $num -le $count ]
        then
                frac=$(bc -l <<< $num/$count)
                samtools view -bs $frac ${c1}.bam > ${c1}_${num}.bam
        fi

	x=$(( $x + 1 ))

done


