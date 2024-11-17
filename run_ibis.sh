#!/bin/bash
# run_ibis.sh
ibis=${1}
bfile=${2}
threads=${3}
BASE_PATH=${4:-/}  # Optional base path, defaults to /

cd "${BASE_PATH}/data/tmp"
$ibis -b $bfile -t $threads -printCoef -ibd2
