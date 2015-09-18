#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi

data=$1
trans=$2
nnet=$3
dir=$4

mkdir -p $dir || exit 1;

fscp=$data/fbank_pitch.scp
cmvn=$data/cmvn.scp
feats="ark:copy-feats scp:$fscp ark:- | apply-cmvn --print-args=false --norm-vars=true scp:$cmvn ark:- ark:- | add-deltas --delta-order=2 ark:- ark:- |"
scores=$dir/scores.txt

# check files exist
required="$trans $nnet $fscp $cmvn"
for f in $required; do
  if [ ! -f $f ]; then
    echo "[error] make_fbank_pitch.sh: no such file $f"
    exit 1;
  fi
done

# extract scores using trained CNN model
nnet-forward --feature-transform=$trans $nnet "$feats" ark,t:- > $scores

[ ! -f $scores ] && echo "[error] something went wrong..." && exit 1;
echo "[info] attribute scores are successfully extracted: $scores";
