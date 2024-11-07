#!/bin/bash

ibis=${1}
bfile=${2}
threads=${3}

cd /data/tmp

$ibis -b $bfile -t $threads -printCoef
