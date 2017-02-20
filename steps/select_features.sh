#!/bin/bash 

nj=$1
feat_select=$2
data=$3
dir=$4
log=$5

mkdir -p $dir $log
for i in `seq 1 $nj`; do
  select-feats $feat_select ark:$data/scores.$i.txt ark,scp,t:$dir/scores.$i.txt,$log/scores.$i.scp
  echo "$data/scores.$i.txt [done]"
done