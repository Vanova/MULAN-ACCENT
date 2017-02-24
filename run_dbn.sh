#!/bin/bash 
# set -x;
# trap read debug;

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

# 1. extract log mel-filter bank features for DBN
if [ $stage -eq 1 ]; then
  for (( i = 0; i < ${#out_sub_dir[@]}; ++i )); do
    # DONT DO CMVN!
    out_dir_data=$out_dir/${out_sub_dir[i]}
    lists_dir=$out_dir_data/lists
    fbank_dir=$out_dir_data/dbn-fbank
    steps/make_fbank.sh $nj $lists_dir $fbank_dir
  done
fi


# 2. forward data through the Neural Network and producing scores
if [ $stage -eq 2 ]; then
  # NOTE: you can fix number of threads for calculate jobs at a time
  echo "LID dataset"
  echo "*** Manner extraction ***"
  for (( i = 0; i < ${#out_sub_dir[@]}; ++i )); do
    out_dir_data=$out_dir/${out_sub_dir[i]}
    fbank_dir=$out_dir_data/dbn-fbank
    trans=model/manner/fbank_to_splice_dbn.trans
    nnet=model/manner/rbm_dbn_2_1024.nnet
    manner_out=$out_dir_data/res/dbn/manner
    steps/forward_dbn_parallel.sh $nj $fbank_dir $trans $nnet $manner_out
    echo "SRE $manner_out [done]"
  done

  echo "*** Place extraction ***"
  for (( i = 0; i < ${#out_sub_dir[@]}; ++i )); do
    out_dir_data=$out_dir/${out_sub_dir[i]}
    fbank_dir=$out_dir_data/dbn-fbank
    trans=model/place/fbank_to_splice_dbn.trans
    nnet=model/place/rbm_dbn_5_1024.nnet
    place_out=$out_dir_data/res/dbn/place
    steps/forward_dbn_parallel.sh $nj $fbank_dir $trans $nnet $place_out
    echo "SRE $place_out [done]"
  done
fi
