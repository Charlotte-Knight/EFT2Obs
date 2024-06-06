#!/usr/bin/env python3

from eftscaling import EFTScaling
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--input', '-i', nargs='+', required=True)
parser.add_argument('--output', '-o', required=True)
args = parser.parse_args()

scalings = [EFTScaling.fromJSON(path) for path in args.input]
scaling = scalings[0]
for other in scalings[1:]:
    scaling += other

print('>> Saving histogram parametrisation to %s' % args.output)
scaling.writeToCommonJSON(args.output, indent=1, decimals=4)
