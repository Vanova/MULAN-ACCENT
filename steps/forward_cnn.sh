#!/bin/bash

#trap read debug

if [ -f path.sh ]; then . ./path.sh; fi

use_gpu=$1
nj=$2
data=$3
trans=$4
nnet=$5
dir=$6

mkdir -p $dir || exit 1;

fscp=$data/feats.scp
cmvn=$data/cmvn.scp
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
feats="ark:copy-feats scp:$fscp ark:- | apply-cmvn --print-args=false --norm-vars=true scp:$cmvn ark:- ark:- | add-deltas --delta-order=2 ark:- ark:- |"

nnet-forward --use-gpu=$use_gpu --feature-transform=$trans $nnet "$feats" ark,t:- > $scores

# run parallel jobs
#run.pl JOB=1:$nj $dir/log/forward.JOB.log \
#  nnet-forward --use-gpu=$use_gpu --feature-transform=$trans $nnet "$feats" ark:- > $scores

[ ! -f $scores ] && echo "[error] something went wrong..." && exit 1;
echo "[info] attribute scores are successfully extracted: $scores";
