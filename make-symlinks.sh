#!/bin/sh

set -eu

for formula in formulas/*; do
  echo $formula
  ln -s $formula $(basename ${formula%-*})
done