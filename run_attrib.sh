#!/bin/bash

. ./path.sh

wavfile=data/wav

# 0. prepare data
local/data_prep.sh

# 1. extract filter bank features
scp=data/waves.scp
fark=data/fbank.ark
fscp=data/fbank.scp
logdir=log
fbank_config=conf/fbank.conf
compute-fbank-feats --verbose=2 --config=$fbank_config scp:$scp ark,scp,t:$fark,$fscp

# 2. run Neural Network forward pass
nnet=model/rbm_dbn_2_1024.nnet
trans=model/fbank_to_splice.trans

# test set to probabilities scores
#nnet-forward --feature-transform=$trans \
# $nnet scp:$scp ark,t:- > out/res_scores.txt

feats="ark:copy-feats scp:$fscp ark:- | add-deltas --delta-order=2 ark:- ark:- |"

nnet-forward --feature-transform=$trans $nnet $feats ark,t:- > $res

nnet-forward --feature-transform=$trans \
$nnet 'ark:copy-feats scp:data/fbank.scp ark:- | add-deltas --delta-order=2 ark:- ark:- |' ark,t:- > out/res_scores.txt 

echo "$0: attributes scores successfully created: out"

