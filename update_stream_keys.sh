#!/bin/bash

keys=( )

STREAM_KEY_1=${STREAM_KEY_1:-test-1} && \
  keys+=( "STREAM_KEY_1" )

STREAM_KEY_2=${STREAM_KEY_2:-test-2} && \
  keys+=( "STREAM_KEY_2" )

for idx in "${!keys[@]}"; do
  arg=${keys[$idx]}
  sed -i -e "s/@$arg@/${!arg}/g" index.html
done
