#!/bin/bash -l

F1=$1

n=$(wc -l $F1 | awk '{print $1}')
x=1
while [ $x -le 1 ] 
do

        string="sed -n ${x}p $F1"
        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1}')
        set -- $var
        c1=$1   ### site_ID ###

        cat ${c1}_?_R1.fastq > ${c1}_R1.fastq
        cat ${c1}_?_R3.fastq > ${c1}_R3.fastq
        
        x=$(( $x + 1 ))

done

