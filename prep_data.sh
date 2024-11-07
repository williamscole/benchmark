#!/bin/bash

prefix=${1}
bfile="/data/input/${prefix}"  # Changed to use /data mount point
mkdir -p /data/tmp  # Changed tmp directory location

if [[ $bfile == *"chr1"* ]]; then
    tmp=""
    for chr in {2..22}
    do
        f=$(sed "s;chr1;chr${chr};g" <(echo $bfile))
        tmp=${tmp}${f}"\n"
    done
    echo -e $tmp > /opt/benchmark/merge_list.txt  # Updated path
    plink2 --bfile $bfile --merge-list /opt/benchmark/merge_list.txt --make-bed --out /data/tmp/tmp
else
    echo "No chr1 in bfile name, copying files directly..."
    cp "${bfile}.bed" "/data/tmp/tmp.bed"
    cp "${bfile}.bim" "/data/tmp/tmp.bim"
    cp "${bfile}.fam" "/data/tmp/tmp.fam"
fi

python3 /opt/benchmark/add_map.py
