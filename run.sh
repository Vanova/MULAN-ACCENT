#!/bin/bash

. ./path.sh

# put your wav files in this folder
wavdir=data/wav

# 0. prepare data
steps/data_prep.sh $wavdir

# 1. extract filter bank features

# TODO check config exists, create folder data-fbank
scp=data/waves.scp
fark=data/fbank.ark
fscp=data/fbank.scp
logdir=log
fbank_config=conf/fbank.conf
compute-fbank-feats --verbose=2 --config=$fbank_config scp:$scp ark,scp,t:$fark,$fscp

# 2. run Neural Network forward pass producing scores
mkdir -p res/manner res/place
trans=model/fbank_to_splice.trans
nnet=model/rbm_dbn_2_1024.nnet
feats="ark:copy-feats scp:$fscp ark:- | add-deltas --delta-order=2 ark:- ark:- |"
res=res/scores.txt
nnet-forward --feature-transform=$trans $nnet "$feats" ark,t:- > $res

[ ! -f $res ] && echo "[error] something went wrong..." && exit 1;
echo "[info] attributes scores successfully extracted: $res";
