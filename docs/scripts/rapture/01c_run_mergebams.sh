#!/bin/bash -l

list=$1

wc=$(wc -l ${list} | awk '{print $1}')

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

	echo "#!/bin/bash -l
	
	#SBATCH -o slurm_outs/01c_mergebams-%j.out
	#SBATCH -J mergebams

	samtools merge ${c1}.merge.bam $c1 ~/projects/rana_rapture/SOMM163b/fastq/align/$c2 ~/projects/rana_rapture/SOMM165/fastq/$c3
	samtools rmdup ${c1}.merge.bam ${c1}.merge.rmdup.bam" > ${c1}.sh
	
	sbatch -t 24:00:00 -p med --mem=2G ${c1}.sh
	sleep 2
	x=$(( $x + 1 ))

done

