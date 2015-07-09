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

# 2. run forward pass
dir=exp/dnn4_pretrain-dbn_dnn_${rbm_hid_layers}_${rbm_hid_units}
testdir=$dir/decode_test
ali=../multi_manner/kaldiformat/ark
mkdir -p $testdir $testdir/log
log=$testdir/log/test.log; hostname>$log

# settings
minibatch_size=256
randomizer_size=32768
verbose=1
feature_transform=$dir/final.feature_transform
test_scp=$data_fmllr/test/feats.scp
labels=$ali/multi_ali_test_post.ark
nnet_best=$dir/final.nnet
# end settings

# test set to probabilities scores
nnet-forward --use-gpu=yes \
 ${feature_transform:+ --feature-transform=$feature_transform} \
 $nnet_best scp:$test_scp ark,t:- > $testdir/res_MLP.txt
