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

# Run analysis with timing
echo "Starting IBIS analysis..."
IBIS_START=$(date +%s)
glen=$(bash "${BASE_PATH}/opt/benchmark/run_ibis.sh" "${BASE_PATH}/opt/ibis/ibis" $bprefix $cpus "${BASE_PATH}" | grep "use:" | awk '{print $5}' | cut -c 5-)
IBIS_END=$(date +%s)
IBIS_TIME=$((IBIS_END - IBIS_START))

echo "Starting CREST analysis..."
CREST_START=$(date +%s)
bash "${BASE_PATH}/opt/benchmark/run_crest.sh" "${BASE_PATH}/opt/crest" $glen "${BASE_PATH}/data/tmp/tmp.bim" "${BASE_PATH}"
CREST_END=$(date +%s)
CREST_TIME=$((CREST_END - CREST_START))

# Create timing report
TOTAL_TIME=$((IBIS_TIME + CREST_TIME))
cat << EOF > timing_report.txt
Benchmark Timing Report
----------------------
IBIS Time:  ${IBIS_TIME} seconds ($(printf "%.2f" $(echo "scale=2; ${IBIS_TIME}/60" | bc)) minutes)
CREST Time: ${CREST_TIME} seconds ($(printf "%.2f" $(echo "scale=2; ${CREST_TIME}/60" | bc)) minutes)
Total Time: ${TOTAL_TIME} seconds ($(printf "%.2f" $(echo "scale=2; ${TOTAL_TIME}/60" | bc)) minutes)
CPUs Used:  ${cpus}
Date:       $(date)
EOF

# Move results to output directory
gzip -f relationships.csv
gzip -f ratio.csv
gzip -f ibis_2nd.coef
gzip -f ibis.coef
gzip -f crest_output.tsv
mkdir -p "${BASE_PATH}/data/results"
mv *csv.gz "${BASE_PATH}/data/results"
mv *coef.gz "${BASE_PATH}/data/results"
mv *tsv.gz "${BASE_PATH}/data/results"
mv timing_report.txt "${BASE_PATH}/data/results"
echo "Done! All results are in ${BASE_PATH}/data/results/"
