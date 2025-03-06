#!/usr/bin/env python3

from eftscaling import EFTScaling
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--input', '-i', nargs='+', required=True)
parser.add_argument('--output', '-o', required=True)
parser.add_argument('--common', action='store_true')
parser.add_argument('--CMS', action='store_true')
args = parser.parse_args()

if args.CMS: assert not args.common, "Cannot use --CMS and --common at the same time"

scalings = [EFTScaling.fromJSON(path) for path in args.input]
scaling = scalings[0]
for other in scalings[1:]:
    scaling += other

print('>> Saving histogram parametrisation to %s' % args.output)
if args.common:
    scaling.writeToCommonJSON(args.output, indent=1, decimals=4)
elif args.CMS:
    scaling.writeToCMSJSON(args.output, indent=1)
else:
    scaling.writeToJSON(args.output, indent=1)
