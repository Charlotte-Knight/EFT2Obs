#!/usr/bin/env bash

set -e

if [[ $# -lt 1 ]]; then
    echo "Insufficient number of arguments, usage is ./run_gridpack.sh name [export = 0 or 1] [cores=N]"
    exit 1
fi

PROCESS=$(basename $1)
CARDDIR=$1
EXPORTRW=${2-0}
CORES=${3-0}
POSTFIX=${4-""}
ALLARGS=("$@")
SETTERS=( "${ALLARGS[@]:4}" )

### SET ENVIRONMENT VARIABLES HERE
RUNLABEL="pilotrun"
###

cp ${CARDS_DIR}/${CARDDIR}/{param,reweight,run,pythia8}_card.dat ${PROC_DIR}/${PROCESS}/Cards/
# Also need to overwrite the default card, or we might lose some options
cp ${CARDS_DIR}/${CARDDIR}/pythia8_card.dat ${PROC_DIR}/${PROCESS}/Cards/pythia8_card_default.dat

pushd ${PROC_DIR}/${PROCESS}
	# Create MG config

	{
	  echo "shower=OFF"
	  echo "reweight=OFF"
	  echo "done"
	  echo "set gridpack True"
		echo "set run_card use_syst False"
	  for i in "${SETTERS[@]}"; do echo ${i}; done
	  echo "done"
	} > mgrunscript

	if [ -d "${PROC_DIR}/${PROCESS}/Events/${RUNLABEL}" ]; then rm -r ${PROC_DIR}/${PROCESS}/Events/${RUNLABEL}; fi

	if [ "$CORES" -gt "0" ]; then
		./bin/generate_events ${RUNLABEL} --nb_core="${CORES}" -n < mgrunscript
	else
		./bin/generate_events ${RUNLABEL} -n < mgrunscript
	fi

	mkdir "gridpack_${PROCESS}"
	pushd "gridpack_${PROCESS}"
		tar -xf ../${RUNLABEL}_gridpack.tar.gz
		mkdir -p madevent/Events/${RUNLABEL}
		cp ../Events/${RUNLABEL}/unweighted_events.lhe.gz madevent/Events/${RUNLABEL}
		pushd madevent
			# Don't want to do the full reweighting now, just get the code compiled
			# We make a dummy card by truncating the real one from the first line
			# that starts with "launch"
			cp Cards/.reweight_card.dat Cards/reweight_card.dat.backup
			sed -n '/^launch/q;p' Cards/reweight_card.dat.backup > Cards/reweight_card.dat
			echo "launch" >> Cards/reweight_card.dat
			# {
			# 	echo "change rwgt_dir rwgt"
			# 	echo "launch"
			# } > Cards/reweight_card.dat
			echo "0" | ./bin/madevent --debug reweight pilotrun
			cp Cards/reweight_card.dat.backup Cards/reweight_card.dat
			if [ "$EXPORTRW" -eq "1" ]; then
				tar -zcf "rw_module_${PROCESS}.tar.gz" rwgt
				cp "rw_module_${PROCESS}.tar.gz" "${PROC_DIR}/"
				echo ">> Reweighting module ${PROC_DIR}/rw_module_${PROCESS}.tar.gz has been successfully created"
			fi
		popd
		rm -r madevent/Events/${RUNLABEL}
		if [ -e ${CARDS_DIR}/${CARDDIR}/madspin_card.dat ] ; then
		    cp ${CARDS_DIR}/${CARDDIR}/madspin_card.dat ${PROC_DIR}/${PROCESS}/Cards/
		    echo "import ../Events/${RUNLABEL}/unweighted_events.lhe.gz" > madspinrun.dat
		    cat ${PROC_DIR}/${PROCESS}/Cards/madspin_card.dat >> madspinrun.dat
		    ${PROC_DIR}/MadSpin/madspin madspinrun.dat 
		    rm madspinrun.dat
		    rm -rf tmp*
		    cp ${PROC_DIR}/${PROCESS}/Cards/madspin_card.dat ./madspin_card.dat
		fi
  		set +e
		tar -zcf "../gridpack_${PROCESS}.tar.gz" ./*
  		set -e
	popd

	rm -r "gridpack_${PROCESS}"
	mv "gridpack_${PROCESS}.tar.gz" "${PROC_DIR}/gridpack_${PROCESS}${POSTFIX}.tar.gz"

popd

echo ">> Gridpack ${PROC_DIR}/gridpack_${PROCESS}${POSTFIX}.tar.gz has been successfully created"
