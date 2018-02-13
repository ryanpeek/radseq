#!/bin/bash -l

#SBATCH -o slurm_outs/06_theta_calc-%j.out
#SBATCH -J theta_stats

echo "Starting Job: "
date

SFSdir='/home/rapeek/projects/rana_rapture/MERGED/thetas'

#ls bamlist_mrg*k | grep "k$" | sed 's/bamlist_mrg_//g' > thetalist_yuba
thetalist=$1

#Now make a script that will go through the list one at a time and run the necessary saf sfs theta and TajD commands
wc=$(wc -l ${thetalist} | awk '{print $1}')
x=1
while [ $x -le $wc ] 
do

        string="sed -n ${x}p ${thetalist}" 
        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1}')   
        set -- $var
        c1=$1
        # check below for POPS or subpops dir
	nInd=$(wc -l bamlists/POPS/bamlist_mrg_${c1} | awk '{print $1}')
	nChr=$(echo $[2* ${nInd}])
	minInd=$(echo $[$nInd/2])

	# 1. Estimate global estimate of SFS, first create site allele frequency file (SAF FILES) for the SFS call
	angsd -bam bamlists/POPS/bamlist_mrg_${c1} -out ${SFSdir}/${c1} -anc final_contigs_300.fasta -fold 1 -minInd $minInd -minQ 20 -minMapQ 10 -GL 1 -doSaf 1 -sites bait_lengths.txt

	# 2. Take saf file and get the maximum likelihood estimate of the site frequency spectra (SFS)
        realSFS -tole 1e-12 ${SFSdir}/${c1}.saf.idx > ${SFSdir}/${c1}.sfs
	
	# 3. Then calculate the thetas per site (or bait) (again from a folded sfs if no ancestral avail)
        angsd -bam bamlists/POPS/bamlist_mrg_${c1} -out ${SFSdir}/${c1} -anc final_contigs_300.fasta -fold 1 -minInd $minInd -minQ 20 -minMapQ 10 -GL 1 -doSaf 1 -doThetas 1 -pest ${SFSdir}/${c1}.sfs -sites bait_lengths.txt

	# 4a. Estimate Tajimas' D and other stats (for each chromo not each site)
        thetaStat do_stat ${SFSdir}/${c1}.thetas.idx

	# 4b. Calc Tajima's D GENOMEWIDE with sliding window analysis of 1 to get Gwd derived TajD, should be idx.pestPG
        thetaStat do_stat ${SFSdir}/${c1}.thetas.idx -win 1 -step 1 -outnames ${SFSdir}/${c1}_gw_thetasWin.gz 

        x=$(( $x + 1 ))

done

echo "Ending Job: "
date

