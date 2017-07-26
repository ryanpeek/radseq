#!/bin/bash -l

list=$1
ref=$2

wc=$(wc -l ${list} | awk '{print $1}')

x=1
while [ $x -le $wc ] 
do
	string="sed -n ${x}p ${list}" 
	str=$($string)

	var=$(echo $str | awk -F"\t" '{print $1, $2}')   
	set -- $var
	c1=$1
	c2=$2

	echo "#!/bin/bash -l
	bwa mem $ref ${c1}.fastq ${c2}.fastq | samtools view -Sb - | samtools sort - ${c1}.sort
	samtools view -f 0x2 -b ${c1}.sort.bam | samtools rmdup - ${c1}.sort.flt.bam" > ${c1}.sh
	sbatch -t 24:00:00 -p med --mem=2G ${c1}.sh

	x=$(( $x + 1 ))

done

