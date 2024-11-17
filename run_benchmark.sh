#!/bin/bash

cpus=${1}
BASE_PATH=${2:-/}  # If $2 is not set, use /

if [ -z "$cpus" ]; then
    echo "Usage: $0 cpus [BASE_PATH]"
    echo "  cpus: number of CPU threads to use"
    echo "  BASE_PATH: optional base path containing opt/ and data/ (defaults to /)"
    exit 1
fi

# Remove trailing slash if present
BASE_PATH=${BASE_PATH%/}

bprefix="${BASE_PATH}/data/tmp/tmp"

# Check for required executables
if ! [ -f "${BASE_PATH}/opt/ibis/ibis" ]; then
    echo "IBIS not found at ${BASE_PATH}/opt/ibis/ibis"
    exit 1
fi

if ! [ -f "${BASE_PATH}/opt/crest/crest_ratio" ]; then
    echo "CREST not found at ${BASE_PATH}/opt/crest/crest_ratio"
    exit 1
fi

cd "${BASE_PATH}/data/tmp"

# Run analysis
glen=$(bash "${BASE_PATH}/opt/benchmark/run_ibis.sh" "${BASE_PATH}/opt/ibis/ibis" $bprefix $cpus | grep "use:" | awk '{print $5}' | cut -c 5-)
bash "${BASE_PATH}/opt/benchmark/run_crest.sh" "${BASE_PATH}/opt/crest" $glen "${BASE_PATH}/data/tmp/tmp.bim"

# Move results to output directory
gzip relationships.csv
gzip ratio.csv
gzip ibis_2nd.coef
gzip ibis.coef
gzip crest_output.tsv
mkdir -p "${BASE_PATH}/data/results"
mv *csv.gz "${BASE_PATH}/data/results"
mv *coef.gz "${BASE_PATH}/data/results"
mv *tsv.gz "${BASE_PATH}/data/results"
echo "Done! All results are in ${BASE_PATH}/data/results/"
