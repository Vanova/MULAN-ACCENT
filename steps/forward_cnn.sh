#!/bin/bash
set -x
trap read debug

if [ -f path.sh ]; then . ./path.sh; fi

use_gpu=$1
nj=$2
data=$3
trans=$4
nnet=$5
dir=$6

mkdir -p $dir || exit 1;
mkdir -p $dir/log || exit 1;

fscp=$data/fbank_pitch.1.scp
cmvn=$data/cmvn.scp

# check files exist
required="$trans $nnet $fscp $cmvn"
for f in $required; do
  if [ ! -f $f ]; then
    echo "[error] make_fbank_pitch.sh: no such file $f"
    exit 1;
  fi
done

# extract scores using trained CNN model
feats="ark:copy-feats scp:$data/fbank_pitch.JOB.scp ark:- | apply-cmvn --print-args=false --norm-vars=true scp:$cmvn ark:- ark:- | add-deltas --delta-order=2 ark:- ark:- |"
# run parallel jobs
# TODO fix JOBs
run.pl JOB=1:$nj $dir/log/forward.JOB.log \
  nnet-forward --use-gpu=$use_gpu --feature-transform=$trans $nnet "$feats" ark,t:- "> $dir/scores.JOB.txt" || exit 1;

#nnet-forward --feature-transform=$trans $nnet "$feats" ark,t:- > $scores

[ ! -f $scores ] && echo "[error] something went wrong..." && exit 1;
echo "[info] attribute scores are successfully extracted: $scores";
