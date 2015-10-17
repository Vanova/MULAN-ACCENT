#!/bin/bash

. ./path.sh

nj=2 # number of parallel jobs
# root folder with audio files to scan
data_dir=data
# audio extension
ext=pcm
# output folder for audio lists, fbanks, attribute scores ...
out_dir=output-data
lists_dir=$out_dir/lists
fbank_dir=$out_dir/data-fbank

# 0. prepare data
steps/data_prep.sh $data_dir $ext $out_dir

# 1. extract log mel-filter bank features
# parallel version
steps/make_fbank_pitch.sh $nj $lists_dir $fbank_dir
steps/compute_cmvn_stats.sh $fbank_dir $fbank_dir

# 2. forward data through the Neural Network and producing scores
use_gpu="no"
# for manner
trans=model/manner/fbank_to_splice_cnn4c_128_4.trans
nnet=model/manner/cnn4c_128_4.nnet
manner_out=$out_dir/res/manner
steps/forward_cnn.sh $use_gpu $nj $fbank_dir $trans $nnet $manner_out

# for place
trans=model/place/fbank_to_splice_cnn4c_128_9.trans
nnet=model/place/cnn4c_128_9.nnet
place_out=$out_dir/res/place
steps/forward_cnn.sh $use_gpu $nj $fbank_dir $trans $nnet $place_out

echo "[info] attributes scores successfully extracted...";
