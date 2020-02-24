#!/usr/bin/env bash
source env.sh

set -e

if [[ $# -lt 1 ]]; then
    echo "Insufficient number of arguments, usage is ./run_gridpack.sh name [export = 0 or 1]"
    exit 1
fi

PROCESS=$1
EXPORTRW=${2-0}
IWD=${PWD}

### SET ENVIRONMENT VARIABLES HERE
RUNLABEL="pilotrun"
###

cp cards/${PROCESS}/{param,reweight,run,pythia8}_card.dat ${MG_DIR}/${PROCESS}/Cards/

pushd ${MG_DIR}/${PROCESS}
# Create MG config
{
  echo "shower=OFF"
  echo "reweight=OFF"
  echo "done"
  echo "set gridpack True"
  echo "done"
} > mgrunscript

if [ -d "${MG_DIR}/${PROCESS}/Events/${RUNLABEL}" ]; then rm -r ${MG_DIR}/${PROCESS}/Events/${RUNLABEL}; fi
./bin/generate_events ${RUNLABEL} -n < mgrunscript

mkdir "gridpack_${PROCESS}"

pushd "gridpack_${PROCESS}"
	tar -xf ../${RUNLABEL}_gridpack.tar.gz
	mkdir -p madevent/Events/${RUNLABEL}
	cp ../Events/${RUNLABEL}/unweighted_events.lhe.gz madevent/Events/${RUNLABEL}
	pushd madevent
		cp Cards/.reweight_card.dat Cards/reweight_card.dat.backup
		{
			echo "change rwgt_dir rwgt"
			echo "launch"
		} > Cards/reweight_card.dat
		echo "0" | ./bin/madevent --debug reweight pilotrun
		cp Cards/reweight_card.dat.backup Cards/reweight_card.dat
		if [ "$EXPORTRW" -eq "1" ]; then
			tar -zcf "rw_module_${PROCESS}.tar.gz" rwgt
			cp "rw_module_${PROCESS}.tar.gz" "${IWD}/"
			echo ">> Reweighting module ${IWD}/rw_module_${PROCESS}.tar.gz has been successfully created"
		fi
	popd
	rm -r madevent/Events/${RUNLABEL}
	tar -zcf "../gridpack_${PROCESS}.tar.gz" ./*
popd

rm -r "gridpack_${PROCESS}"
cp "gridpack_${PROCESS}.tar.gz" "${IWD}/gridpack_${PROCESS}.tar.gz"

# cp "${RUNLABEL}_gridpack.tar.gz" "${IWD}/gridpack_${PROCESS}.tar.gz"
popd

echo ">> Gridpack ${IWD}/gridpack_${PROCESS}.tar.gz has been successfully created"
