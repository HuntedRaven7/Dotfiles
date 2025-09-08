#!/usr/bin/env bash

top_gen=$(nh os info 2>/dev/null | awk '/^ *[0-9]+/ { print $1; exit }')
echo "$top_gen"

