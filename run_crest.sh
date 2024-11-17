#!/bin/bash
set -e
set -x

crest_dir=${1}
glen=${2}
bim=${3}

cd /data/tmp

echo "Individual1     Individual2     Kinship_Coefficient     IBD2_Fraction   Segment_Count   Degree" > ibis_2nd.coef

cat ibis.coef | awk '{ if ($6 < 4 && $6 > 0) print }' >> ibis_2nd.coef || {
    exit 1
}

echo "Running crest_ratio"
${crest_dir}/crest_ratio -i ibis.seg -r ibis_2nd.coef -o ratio --ibd2 0.17 --pc --kinship_lw 0.05 --kinship_up 0.25  || {
    exit 1
}

echo "Running CREST_relationships"
${crest_dir}/CREST_relationships.py -i ratio.csv --total_len $glen || {
    exit 1
}

echo "Running CREST_sex_inference.py"
${crest_dir}/CREST_sex_inference.py -i ibis.seg -m /opt/benchmark/refined_mf.simmap -b ${bim} -o crest_output.tsv -k ibis_2nd.coef || {
    exit 1
}
