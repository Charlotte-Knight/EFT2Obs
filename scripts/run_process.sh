#!/usr/bin/env bash

pushd ${EFT2OBS_DIR}
  source env.sh
popd

set -e

if [[ $# -lt 1 ]]; then
    echo "Insufficient number of arguments, usage is ./run_process.sh name [cores=N] RWPOINT"
    exit 1
fi

PROCESS=$(basename $1)
CARDDIR=$1
CORES=${2-0}
RWPOINT=${3-rw0000}
IWD=${PWD}

echo "Running process ${PROCESS} with ${CORES} cores at rwpoint ${RWPOINT}"

### SET ENVIRONMENT VARIABLES HERE
RUNLABEL="pilotrun"
###

cp ${CARDS_DIR}/${CARDDIR}/{param,reweight,run,pythia8}_card.dat ${PROC_DIR}/${PROCESS}/Cards/
# Also need to overwrite the default card, or we might lose some options
cp ${CARDS_DIR}/${CARDDIR}/pythia8_card.dat ${PROC_DIR}/${PROCESS}/Cards/pythia8_card_default.dat

setters=$(${EFT2OBS_DIR}/scripts/extract_setters.py ${CARDS_DIR}/${CARDDIR}/reweight_card.dat $RWPOINT )

pushd ${PROC_DIR}/${PROCESS}
# Create MG config

nevents=10000

{
  echo "shower=OFF"
  echo "reweight=OFF"
	echo "done"
  echo "set gridpack False"
	echo "set nevents $nevents"
	echo $setters
	echo "done"
} > mgrunscript

cat mgrunscript

if [ -d "${PROC_DIR}/${PROCESS}/Events/${RUNLABEL}" ]; then rm -r ${PROC_DIR}/${PROCESS}/Events/${RUNLABEL}; fi

./bin/generate_events ${RUNLABEL} --nb_core="${CORES}" < mgrunscript > generate_events.log
