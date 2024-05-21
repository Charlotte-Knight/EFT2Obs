#!/usr/bin/env bash

source env.sh

{
  for model in $@ ; do echo "import model $model" ; done
} > mgrunscript

${MG_DIR}/bin/mg5_aMC < mgrunscript
