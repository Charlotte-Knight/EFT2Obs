#!/usr/bin/env bash

set -e

if [[ $# -lt 1 ]]; then
    echo "Insufficient number of arguments, usage is ./setup_process.sh [name]]"
    exit 1
fi

PROCESS=$1

pushd "${PROC_DIR}"
if [ -d "${PROCESS##*/}" ]; then
	echo "Process directory already exists, remove this first to run setup"
	exit 1
fi
${EFT2OBS_DIR}/${MG_DIR}/bin/mg5_aMC "${CARDS_DIR}/${PROCESS}/proc_card.dat"
popd

if [ -f "${CARDS_DIR}/${PROCESS}/run_card.dat" ]; then
	echo ">> File ${CARDS_DIR}/${PROCESS}/run_card.dat already exists, it will not be modified"
else
	echo ">> File ${CARDS_DIR}/${PROCESS}/run_card.dat does not exist, copying from ${PROC_DIR}/${PROCESS##*/}/Cards/run_card.dat"
	cp "${PROC_DIR}/${PROCESS##*/}/Cards/run_card.dat" "${CARDS_DIR}/${PROCESS}/run_card.dat"
fi

if [ -f "${CARDS_DIR}/${PROCESS}/pythia8_card.dat" ]; then
	echo ">> File ${CARDS_DIR}/${PROCESS}/pythia8_card.dat already exists, it will not be modified"
else
	echo ">> File ${CARDS_DIR}/${PROCESS}/pythia8_card.dat does not exist, copying from ${PROC_DIR}/${PROCESS##*/}/Cards/pythia8_card_default.dat"
	cp "${PROC_DIR}/${PROCESS##*/}/Cards/pythia8_card_default.dat" "${CARDS_DIR}/${PROCESS}/pythia8_card.dat"
fi
