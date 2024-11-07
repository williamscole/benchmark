#!/bin/bash

# Available CPUs
cpus=${1}

bprefix="/data/tmp/tmp"  # Updated path

# Rest of script remains the same but uses absolute paths
if ! [ -f "/opt/ibis/ibis" ]; then
    echo "IBIS not found"
    exit 1
fi

if ! [ -f "/opt/crest/crest_ratio" ]; then
    echo "CREST not found"
    exit 1
fi

# Run analysis
glen=$(bash /opt/benchmark/run_ibis.sh /opt/ibis/ibis $bprefix $cpus | grep "use:" | awk '{print $5}' | cut -c 5-)
bash /opt/benchmark/run_crest.sh /opt/crest $glen /data/tmp/tmp.bim

# Move results to output directory
gzip relationships.csv
gzip ratio.csv
gzip ibis_2nd.coef
gzip ibis.coef
gzip crest_output.tsv
mkdir -p /data/results
mv *csv.gz /data/results
mv *coef.gz /data/results
mv *tsv.gz /data/results
echo "Done! All results are in /data/results/"
