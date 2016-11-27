#!/bin/bash
# set -x
#trap read debug
#####
# Run the data forward pass in the parallel queue on the CPU
# NOTE: be careful with running on gpu, data files should fit the memory!!!
#####

if [ -f path.sh ]; then . ./path.sh; fi

nj=$1
data=$2
trans=$3
nnet=$4
dir=$5

mkdir -p $dir || exit 1;

feats_scp=$data/feats.scp
cmvn=$data/cmvn.scp
scores=$dir/scores.txt

# check files exist
required="$trans $nnet $feats_scp $cmvn"
for f in $required; do
  if [ ! -f $f ]; then
    echo "[error] make_fbank_pitch.sh: no such file $f"
    exit 1;
  fi
done

# Run the data forward pass in the parallel queue on the CPU
#TODO NOTE: be careful with running on gpu, it should fit the memory!!!
use_gpu=no
for i in `seq 1 $nj`; do
	fscp=$data/fbank_pitch.$i.scp
	cmvn_opts="apply-cmvn --print-args=false --norm-vars=true scp:$cmvn ark:- ark:-"
	delta_opts="add-deltas --delta-order=2 ark:- ark:-"
	feats="ark:copy-feats scp:$fscp ark:- | $cmvn_opts | $delta_opts |"

  	nnet-forward --use-gpu=$use_gpu --feature-transform=$trans $nnet "$feats" ark,t:- > $dir/scores.$i.txt
done

# check number of extracted score files
for i in `seq 1 $nj`; do
	fb="$data/fbank_pitch.$i.scp"
	scores="$dir/scores.$i.txt"
	nf=`cat $fb | wc -l`
	nu=`grep -o "\[" $scores | wc -l`

	if [ $nf -ne $nu ]; then
	  echo "$0: it seems not all of the feature files were successfully processed ($nf != $nu):"
	  echo "compare $fb vs $scores"
	  exit 1;
	fi
done

[ ! -f $scores ] && echo "[error] something went wrong..." && exit 1;
echo "[info] attribute scores are successfully extracted: $scores";