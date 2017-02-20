#!/bin/bash 
# set -x;
# trap read debug;

stage=$1

. ./path.sh

nj=20 # number of parallel jobs
# root folder with audio files to scan
dataset_dir=/home/vano/Storage/Datasets
# output folder for audio lists, fbanks, attribute scores ...
out_dir_data=/home/vano/Storage/projects_data/accent_recognition/mulan_extractor/data
out_dir_ubm=/home/vano/Storage/projects_data/accent_recognition/mulan_extractor/ubm_tmatrix

# SRE 08 file lists
list_data=data/filelist/data_fix.txt
list_ubm=data/filelist/UBM-and-Tmatrix-list_fix.txt

# 0. prepare data
# input list of SRE08 (data and ubm) file names (see email lists)
if [ $stage -eq 0 ]; then
  steps/data_prep_by_list.sh $list_data $dataset_dir $out_dir_data
  steps/data_prep_by_list.sh $list_ubm $dataset_dir $out_dir_ubm
fi

# 1. extract log mel-filter bank features, binary encoding
# data
if [ $stage -eq 1 ]; then
  fbank_dir=$out_dir_data/data-fbank
  lists_dir=$out_dir_data/lists
  steps/make_fbank_pitch.sh $nj $lists_dir $fbank_dir
  steps/compute_cmvn_stats.sh $fbank_dir $fbank_dir
  # UBM & T-matrix
  fbank_dir=$out_dir_ubm/data-fbank
  lists_dir=$out_dir_ubm/lists
  steps/make_fbank_pitch.sh $nj $lists_dir $fbank_dir
  steps/compute_cmvn_stats.sh $fbank_dir $fbank_dir
fi

# NOTE: compile last KALDI src with MFoM UvZ loss
# 2. forward data through the Neural Network and producing scores
if [ $stage -eq 2 ]; then
  echo "*** Manner extraction ***"
  echo "SRE data list"
  fbank_dir=$out_dir_data/data-fbank
  trans=model/manner/fbank_to_splice_cnn4c_128_3_uvz_mfom.trans
  nnet=model/manner/cnn4c_128_3_uvz_mfom.nnet
  manner_out=$out_dir_data/res/manner
  steps/forward_cnn_parallel.sh $nj $fbank_dir $trans $nnet $manner_out
  echo "SRE UBM list"
  fbank_dir=$out_dir_ubm/data-fbank
  trans=model/manner/fbank_to_splice_cnn4c_128_3_uvz_mfom.trans
  nnet=model/manner/cnn4c_128_3_uvz_mfom.nnet
  manner_out=$out_dir_ubm/res/manner
  steps/forward_cnn_parallel.sh $nj $fbank_dir $trans $nnet $manner_out

  echo "*** Place extraction ***"
  echo "SRE data list"
  fbank_dir=$out_dir_data/data-fbank
  trans=model/place/fbank_to_splice_cnn4c_128_7_uvz_mfom.trans
  nnet=model/place/cnn4c_128_7_uvz_mfom.nnet
  place_out=$out_dir_data/res/place
  steps/forward_cnn_parallel.sh $nj $fbank_dir $trans $nnet $place_out
  echo "SRE UBM list"
  fbank_dir=$out_dir_ubm/data-fbank
  trans=model/place/fbank_to_splice_cnn4c_128_7_uvz_mfom.trans
  nnet=model/place/cnn4c_128_7_uvz_mfom.nnet
  place_out=$out_dir_ubm/res/place
  steps/forward_cnn_parallel.sh $nj $fbank_dir $trans $nnet $place_out

  echo "*** Fusion extraction ***"
  echo "SRE data list"
  fbank_dir=$out_dir_data/data-fbank
  trans=model/fusion/fbank_to_splice_cnn4c_128_5_uvz_mfom.trans
  nnet=model/fusion/cnn4c_128_5_uvz_mfom.nnet
  fusion_out=$out_dir_data/res/fusion
  steps/forward_cnn_parallel.sh $nj $fbank_dir $trans $nnet $fusion_out
  echo "SRE UBM list"
  fbank_dir=$out_dir_ubm/data-fbank
  trans=model/fusion/fbank_to_splice_cnn4c_128_5_uvz_mfom.trans
  nnet=model/fusion/cnn4c_128_5_uvz_mfom.nnet
  fusion_out=$out_dir_ubm/res/fusion
  steps/forward_cnn_parallel.sh $nj $fbank_dir $trans $nnet $fusion_out
fi

# 3. split fusion on fusion_manner and fusion_place parts
if [ $stage -eq 3 ]; then
  echo "*** Select MANNER part from FUSION scores ***"
  echo "SRE data list"
  feat_select="2,4,9,10,12,13,15,16" # with 'other' and 'sil'
  fusion_in=$out_dir_data/res/fusion
  fusion_out=$out_dir_data/res/fusion_manner
  log=$fusion_out/log
  steps/select_features.sh $nj $feat_select $fusion_in $fusion_out $log
  echo "SRE UBM list"
  fusion_in=$out_dir_ubm/res/fusion
  fusion_out=$out_dir_ubm/res/fusion_manner
  log=$fusion_out/log
  steps/select_features.sh $nj $feat_select $fusion_in $fusion_out $log  

  echo "*** Select PLACE part from FUSION scores ***"
  echo "SRE data list"
  feat_select="0,1,3,5,6,7,8,10,11,12,14" # with 'other' and 'sil'
  fusion_in=$out_dir_data/res/fusion
  fusion_out=$out_dir_data/res/fusion_place
  log=$fusion_out/log
  steps/select_features.sh $nj $feat_select $fusion_in $fusion_out $log
  echo "SRE UBM list"
  fusion_in=$out_dir_ubm/res/fusion
  fusion_out=$out_dir_ubm/res/fusion_place
  log=$fusion_out/log
  steps/select_features.sh $nj $feat_select $fusion_in $fusion_out $log  
fi