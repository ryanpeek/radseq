#!/bin/bash -l

list=$1
#ref=$2

wc=$(wc -l ${list} | awk '{print $1}')

x=1
while [ $x -le $wc ] 
do
	string="sed -n ${x}p ${list}" 
	str=$($string)

	var=$(echo $str | awk -F"\t" '{print $1}')   
	set -- $var
	c1=$1
	#c2=$2

	echo "#!/bin/bash -l
	
	#SBATCH -o slurm_outs/01b_sortbamflt-%j.out
	#SBATCH -J sortbamflt
	
	samtools view -f 0x2 -b ${c1} > ${c1}.sort.flt1.bam" > ${c1}.sh
	# | samtools rmdup - ${c1}.sort.flt.bam" > ${c1}.sh
	
	sbatch -t 24:00:00 -p med --mem=2G ${c1}.sh
	sleep 5
	x=$(( $x + 1 ))

done

