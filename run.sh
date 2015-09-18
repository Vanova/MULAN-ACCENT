#!/bin/bash

. ./path.sh

# put your wav files in this folder
wavdir=data/wav

# 0. prepare data
steps/data_prep.sh $wavdir

# 1. extract log mel-filter bank features
steps/make_fbank_pitch.sh data/lists data-fbank/log data-fbank
steps/compute_cmvn_stats.sh data-fbank data-fbank/log data-fbank

# 2. forward data through the Neural Network and producing scores
# for manner
trans=model/manner/fbank_to_splice_cnn4c_1024_2.trans
nnet=model/manner/cnn4c_1024_2.nnet
steps/forward_cnn.sh data-fbank $trans $nnet res/manner
# for place
trans=model/place/fbank_to_splice_cnn4c_512_3.trans
nnet=model/place/cnn4c_512_3.nnet
steps/forward_cnn.sh data-fbank $trans $nnet res/place

echo "[info] attributes scores successfully extracted...";
