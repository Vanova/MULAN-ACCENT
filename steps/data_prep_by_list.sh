#!/bin/bash 

##
# Prepare data lists for feature extraction from dataset lists
##

list_to_scan=$1
dataset_dir=$2
outdir=$3

if [ -f path.sh ]; then . ./path.sh; fi

# directory for wav lists
listdir=$outdir/lists
mkdir -p $listdir || exit 1;

wavlist=$listdir/waves.list
scp=$listdir/waves.scp

# create list with full path to files
while read line; do
  # take only file name in the dataset folder
	file=`echo "$line" | cut -d' ' -f1`
  full_name=$dataset_dir/$file
  # check file exist
  [ ! -f $full_name ] && echo "[error] no such audio file..." && exit 1;
  echo $full_name  
done < $list_to_scan > $wavlist;

# iterate waves list and prepare kaldi scp: [wavID] [file full path]
while read line; do
	full_name=$line	
  # check file exist
  [ ! -f "$full_name" ] && echo "[error] no such audio file..." && exit 1;
  # parse file name only (without path and ext) 
  name=`basename $full_name`
  utterance_id=${name%.*}
  echo $utterance_id "sox $full_name -r 8000 -c 1 -t wav -b 16 - |"
done < $wavlist > $scp;

cat $scp | sort -u -k1,1 -o $scp

# check number of files
nf=`cat $list_to_scan | wc -l` 
nu=`cat $scp | wc -l` 
if [ $nf -ne $nu ]; then
  echo "[INFO] It seems not all the audio files exist ($nf != $nu);"
  echo "compare $list_to_scan and $scp"
  exit 1;
fi

echo "$0: data lists prepared successfully: $nu utterances"
