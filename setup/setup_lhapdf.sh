#!/usr/bin/env bash
set -e

IWD=${PWD}
source env.sh

if [ -z "${LHAPDF_CONFIG_PATH}" ]; then echo "ERROR: environment variable LHAPDF_CONFIG_PATH is not set"; exit 1; fi

if [ ${EFTOBS_LOCAL_LHAPDF} -eq 1 ]; then
  echo "ERROR: environment variable LHAPDF_CONFIG_PATH is not set" 
  LHAPDF_VERSION="LHAPDF-6.5.3"
  wget "https://lhapdf.hepforge.org/downloads/?f=${LHAPDF_VERSION}.tar.gz" -O "${LHAPDF_VERSION}.tar.gz"
  tar xf "${LHAPDF_VERSION}.tar.gz"
  rm "${LHAPDF_VERSION}.tar.gz"
  mkdir lhapdf
  pushd "${LHAPDF_VERSION}"
	  PYTHON_VERSION=3 ./configure --prefix="${IWD}/lhapdf/"
    make
    make install
  popd
  rm -r "${LHAPDF_VERSION}"
fi