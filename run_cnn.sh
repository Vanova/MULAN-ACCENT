#!/bin/bash 
# set -x;
# trap read debug;

### run: ./run_cnn.sh 1 # with number of stage

stage=$1

. ./path.sh

nj=20 # number of parallel jobs

###
# SRE08 dataset feature extraction
# for the foreign accent recognition task
###

# root folder with audio files to scan: SRE08/ and SRE08-additional/
dataset_dir=/data3/pums/Accent
# output folder for audio lists, fbanks, attribute scores ...
out_dir=/home1/ivan/projects_data/MULAN-ACCENT
out_sub_dir=( "data" "ubm_tmatrix" )

# SRE08 file lists to scan
lst_dir=data/filelist
scan_lists=( "data_fix.txt" "UBM-and-Tmatrix-list_fix.txt" )

# 0. prepare data
# input list of SRE08 (data and ubm) file names (see email lists)
if [ $stage -eq 0 ]; then
  # NOTE: don't forget to fix sox resampling rate
  for (( i = 0; i < ${#scan_lists[@]}; ++i )); do
    steps/data_prep_by_list.sh $lst_dir/${scan_lists[i]} $dataset_dir $out_dir/${out_sub_dir[i]}        
  done
fi

# 1. extract log mel-filter bank and pitch features for CNN, binary encoding
if [ $stage -eq 1 ]; then
  for (( i = 0; i < ${#out_sub_dir[@]}; ++i )); do
    out_dir_data=$out_dir/${out_sub_dir[i]}
    fbank_dir=$out_dir_data/cnn-fbank
    lists_dir=$out_dir_data/lists
    steps/make_fbank_pitch.sh $nj $lists_dir $fbank_dir
    steps/compute_cmvn_stats.sh $fbank_dir $fbank_dir   
  done
fi

# 2. forward data through the Neural Network and producing scores
if [ $stage -eq 2 ]; then
  # NOTE: you can fix number of threads for calculate jobs at a time  
  echo "------------------SRE dataset---------------------"
  echo "*** Manner extraction ***"
  for (( i = 0; i < ${#out_sub_dir[@]}; ++i )); do
    out_dir_data=$out_dir/${out_sub_dir[i]}
    fbank_dir=$out_dir_data/cnn-fbank
    trans=model/manner/fbank_to_splice_cnn4c_128_3_uvz_mfom.trans
    nnet=model/manner/cnn4c_128_3_uvz_mfom.nnet
    manner_out=$out_dir_data/res/cnn/manner
    steps/forward_cnn_parallel.sh $nj $fbank_dir $trans $nnet $manner_out
    echo "SRE $manner_out [done]"
  done
  
  echo "*** Place extraction ***"
  for (( i = 0; i < ${#out_sub_dir[@]}; ++i )); do
    out_dir_data=$out_dir/${out_sub_dir[i]}
    fbank_dir=$out_dir_data/cnn-fbank
    trans=model/place/fbank_to_splice_cnn4c_128_7_uvz_mfom.trans
    nnet=model/place/cnn4c_128_7_uvz_mfom.nnet
    place_out=$out_dir_data/res/place
    steps/forward_cnn_parallel.sh $nj $fbank_dir $trans $nnet $place_out
    echo "SRE $place_out [done]"
  done
  
  echo "*** Fusion extraction ***"
  for (( i = 0; i < ${#out_sub_dir[@]}; ++i )); do
    out_dir_data=$out_dir/${out_sub_dir[i]}
    fbank_dir=$out_dir_data/cnn-fbank
    trans=model/fusion/fbank_to_splice_cnn4c_128_5_uvz_mfom.trans
    nnet=model/fusion/cnn4c_128_5_uvz_mfom.nnet
    fusion_out=$out_dir_data/res/cnn/fusion
    steps/forward_cnn_parallel.sh $nj $fbank_dir $trans $nnet $fusion_out
    echo "SRE $fusion_out [done]"
  done
fi

# 3. split fusion on fusion_manner and fusion_place parts
if [ $stage -eq 3 ]; then
  echo "*** Select MANNER part from FUSION scores ***"
  feat_select="2,4,9,10,12,13,15,16" # with 'other' and 'sil'
  for (( i = 0; i < ${#out_sub_dir[@]}; ++i )); do
    out_dir_data=$out_dir/${out_sub_dir[i]}
    fusion_in=$out_dir_data/res/cnn/fusion
    fusion_out=$out_dir_data/res/cnn/fusion_manner
    log=$fusion_out/log
    steps/select_features.sh $nj $feat_select $fusion_in $fusion_out $log
    echo "SRE $fusion_out [done]"
  done

  echo "*** Select PLACE part from FUSION scores ***"
  feat_select="0,1,3,5,6,7,8,10,11,12,14" # with 'other' and 'sil'
  for (( i = 0; i < ${#out_sub_dir[@]}; ++i )); do
    out_dir_data=$out_dir/${out_sub_dir[i]}
    fusion_in=$out_dir_data/res/cnn/fusion
    fusion_out=$out_dir_data/res/cnn/fusion_place
    log=$fusion_out/log
    steps/select_features.sh $nj $feat_select $fusion_in $fusion_out $log  
    echo "SRE $fusion_out [done]"
  done  
fi