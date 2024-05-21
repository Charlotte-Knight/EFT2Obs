#!/usr/bin/env bash

source env.sh

for pdf in $@ ; do
  python3 ./lhapdf/bin/lhapdf install $pdf
done
