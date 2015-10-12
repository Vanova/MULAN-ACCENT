#!/bin/bash

. ./path.sh

# root folder with audio files to scan
data_dir=data
# audio extension
ext=wav
# output folder for audio lists, fbanks, attribute scores ...
out_dir=data-out
fbank_dir=$out_dir/data-fbank
lists_dir=$out_dir/lists

# 0. prepare data
steps/data_prep.sh $data_dir $ext $out_dir

# 1. extract log mel-filter bank features
steps/make_fbank_pitch.sh $lists_dir $fbank_dir
steps/compute_cmvn_stats.sh $fbank_dir $fbank_dir

# 2. forward data through the Neural Network and producing scores
# for manner
trans=model/manner/fbank_to_splice_cnn4c_1024_2.trans
nnet=model/manner/cnn4c_1024_2.nnet
manner_out=$out_dir/res/manner
steps/forward_cnn.sh $fbank_dir $trans $nnet $manner_out
# for place
trans=model/place/fbank_to_splice_cnn4c_512_3.trans
nnet=model/place/cnn4c_512_3.nnet
place_out=$out_dir/res/place
steps/forward_cnn.sh $fbank_dir $trans $nnet $place_out

echo "[info] attributes scores successfully extracted...";
