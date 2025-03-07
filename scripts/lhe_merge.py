#!/usr/bin/env python3

import sys
import gzip

def gread(filename):
  if ".gz" in filename:
    with gzip.open(filename, "rt") as f:
      return f.read()
  else:
    with open(filename, "r") as f:
      return f.read()

def merge_lhe_files(lhe_files, output_file):
  assert len(lhe_files) > 0, "No LHE files to merge"

  if len(lhe_files) == 1:
    output_lhe = gread(lhe_files[0])

  else:
    output_lhe = gread(lhe_files[0]).split("\n</LesHouchesEvents>")[0]

    for lhe_file in lhe_files[1:-1]:
      output_lhe += gread(lhe_file).split("</init>")[1].split("\n</LesHouchesEvents>")[0]

    output_lhe += gread(lhe_files[-1]).split("</init>")[1]

  with open(output_file, 'w') as f:
    f.write(output_lhe)

if __name__=="__main__":
  """./lhe_merge.py output.lhe input1.lhe.gz input2.lhe ..."""
  output_file = sys.argv[1]
  lhe_files = sys.argv[2:]
  merge_lhe_files(lhe_files, output_file)