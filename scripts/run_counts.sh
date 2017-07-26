#!/bin/bash -l

list=$1

wc=$(wc -l ${list} | awk '{print $1}')

rm count?_*.txt

x=1
while [ $x -le $wc ] 
do
	string="sed -n ${x}p ${list}" 
	str=$($string)

	var=$(echo $str | awk -F"\t" '{print $1, $2, $3}')   
	set -- $var
	c1=$1
	c2=$2
	c3=$3


	samtools flagstat ${c1}.sort.bam | sed -n 1p | cut -d" " -f1 >> count1_reads.txt
	samtools flagstat ${c1}.sort.bam | sed -n 3p | cut -d" " -f1 >> count2_mapped.txt
	samtools flagstat ${c1}.sort.bam | sed -n 7p | cut -d" " -f1 >> count3_paired.txt
	samtools flagstat ${c1}.sort.flt.bam | sed -n 1p | cut -d" " -f1 >> count4_unique.txt

	x=$(( $x + 1 ))

done


