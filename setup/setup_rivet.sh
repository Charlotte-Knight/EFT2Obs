#!/usr/bin/env bash
set -e

source env.sh

if [ -z "${RIVET_VERSION}" ]; then echo "ERROR: environment variable RIVET_VERSION is not set"; exit 1; fi

mkdir rivet
pushd rivet
wget "https://gitlab.com/hepcedar/rivetbootstrap/raw/${RIVET_VERSION}/rivet-bootstrap" -O rivet-bootstrap
#enable_root=no PYTHON_EXE=python3 PYTHON_VERSION=3 USE_VENV=0 HEPMC3=0 HEPMC_VERSION="2.06.11" INSTALL_PREFIX=/eft2obs/rivet bash rivet-bootstrap
enable_root=no PYTHON_EXE=python3 PYTHON_VERSION=3 USE_VENV=0 HEPMC3=0 HEPMC_VERSION="2.06.11" bash rivet-bootstrap
popd
