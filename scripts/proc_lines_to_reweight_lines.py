#!/usr/bin/env python3

import sys

proc_card_path = sys.argv[1]
reweight_card_path = sys.argv[2]

with open(proc_card_path, 'r') as f:
  lines = f.read().split("\n")

prepend_rw_lines = []
for line in lines:
  if "generate" in line:
    prepend_rw_lines.append(line.replace("generate", "change process"))
  elif "add process" in line:
    prepend_rw_lines.append(line.replace("add process", "change process") + " --add")

with open(reweight_card_path, 'r') as f:
  reweight_lines = f.read().split("\n")

with open(reweight_card_path, 'w') as f:
  reweight_lines = prepend_rw_lines + reweight_lines
  f.write("\n".join(reweight_lines))