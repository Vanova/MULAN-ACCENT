#!/bin/bash

. ./path.sh

wavdir=data/wav

# 0. prepare data
steps/data_prep.sh $wavdir

# 1. extract filter bank features
scp=data/waves.scp
fark=data/fbank.ark
fscp=data/fbank.scp
logdir=log
fbank_config=conf/fbank.conf
compute-fbank-feats --verbose=2 --config=$fbank_config scp:$scp ark,scp,t:$fark,$fscp

# 2. run Neural Network forward pass producing scores
trans=model/fbank_to_splice.trans
nnet=model/rbm_dbn_2_1024.nnet
feats="ark:copy-feats scp:$fscp ark:- | add-deltas --delta-order=2 ark:- ark:- |"
res=res/scores1.txt
nnet-forward --no-softmax --feature-transform=$trans $nnet "$feats" ark,t:- > $res

[ ! -f $res ] && echo "[error] something went wrong..." && exit 1;
echo "$0: attributes scores successfully extracted: $res";
