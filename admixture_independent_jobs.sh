#!/bin/bash
set -euo pipefail

echo "Running ADMIXTURE with K=$1, replicate=$2"
date

source /opt/conda/etc/profile.d/conda.sh
conda activate base

FILENAME="Data4ADMIXTUREpruned"
K=$1
RUN=$2

#OUTDIR="K${K}_Run${RUN}"
#mkdir -p ${OUTDIR}
#cd ${OUTDIR}

admixture -s time --cv ${FILENAME}.bed ${K} -j16 | tee log.${FILENAME}_K${K}.RUN${RUN}.out
mv ${FILENAME}.${K}.P ${FILENAME}_K${K}.Run${RUN}.P
mv ${FILENAME}.${K}.Q ${FILENAME}_K${K}.Run${RUN}.Q
#mv ../${FILENAME}.${K}.P ${FILENAME}_K${K}.Run${RUN}.P
#mv ../${FILENAME}.${K}.Q ${FILENAME}_K${K}.Run${RUN}.Q

#cd ..
