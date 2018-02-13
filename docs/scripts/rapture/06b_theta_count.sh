#!/bin/bash

#SBATCH -o slurm_outs/06b_theta_count-%j.out
#SBATCH -J thetacount
#SBATCH --mem 16G

echo "Starting Job: "
date

thetadir='/home/rapeek/projects/rana_rapture/MERGED/thetas'

#ls ${thetadir}/*idx.pestPG > listPG
#ls ${thetadir}/*gz.pestPG > list_gw_PG
#input="list_gw_PG"

input=$1 # a list of the pestPG

wc=$(wc -l ${thetadir}/${input} | awk '{print $1}')
x=1

#echo "#id tw tp ns" > theta_chromo
echo "#id tw tp tD ns" > theta_chromo
while [ $x -le $wc ] 
do

        string="sed -n ${x}p ${thetadir}/${input}" 
        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1,$2,$3}')   
        set -- $var
        c1=$1
        c2=$2
        c3=$3
#awk '{ Tw += $4 }; { Tp += $5 }; { Td += $9 }; { sites += $14 }; END { print Tw / NR" "Tp / NR" "Td / NR" "sites }'
stats=$(cat ${thetadir}/${c1} | awk '{ Tw += $4 }; { Tp += $5 }; { Td += $9 }; { sites += $14 }; END { print Tw / sites" "Tp / sites " "Td / sites" "sites }')
echo "${c1} $stats" >> theta_chromo

        x=$(( $x + 1 ))

done

