#!/bin/bash

. ./path.sh

wavfile=data/wav

# 0. prepare data
local/data_prep.sh

# 1. extract filter bank features
scp=data/waves.scp
ark=data/waves.ark
logdir=log
fbank_config=conf/fbank.conf
compute-fbank-feats --verbose=2 --config=$fbank_config scp:$scp ark,t:$ark

# 2. run Neural Network forward pass
$nnet=model/rbm_dbn_2_1024.nnet
$trans=model/fbank_to_splice.trans

# test set to probabilities scores
#nnet-forward --feature-transform=$trans \
# $nnet scp:$scp ark,t:- > out/res_scores.txt

feats="ark:copy-feats scp:$scp ark:- |"
feats="$feats add-deltas --delta-order=2 ark:- ark:- |"

nnet-forward --feature-transform=$trans \
$nnet $feats ark,t:- > out/res_scores.txt


