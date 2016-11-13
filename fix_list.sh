#!/bin/bash
##
# Fix paths in the original filelists
##
dataset_dir=/home/vano/Storage/Datasets
# orig_list=data/filelist/data.txt
# fix_list=data/filelist/data_fix.txt
orig_list=data/filelist/UBM-and-Tmatrix-list.txt
fix_list=data/filelist/UBM-and-Tmatrix-list_fix.txt

while read line; do
	path=`echo "$line" | cut -d' ' -f1`
	# take path to file from the dataset root
	correct_path=`echo "$path" | cut -d'/' -f5-`
  # check file exist
  [ ! -f $dataset_dir/$correct_path ] && echo "[error] no such audio file..." && exit 1;
  rest_line=`echo "$line" | cut -d' ' -f2-`
  echo  "$correct_path $rest_line"
done < $orig_list > $fix_list;

nf=`cat $orig_list | wc -l` 
nu=`cat $fix_list | wc -l` 
if [ $nf -ne $nu ]; then
  echo "[INFO] It seems not all the audio files exist ($nf != $nu);"
  echo "compare $orig_list and $fix_list"
  exit 1;
fi

echo "$0: data lists prepared successfully: $nu utterances"
