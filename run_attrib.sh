#!/bin/bash

. ./path.sh

wavfile=data/wav

# 0. prepare data
steps/data_prep.sh

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
res=res/scores.txt

nnet-forward --feature-transform=$trans $nnet "$feats" ark,t:- > $res


echo "$0: attributes scores successfully extracted: $res"

