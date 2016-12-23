#!/bin/bash
# set -x
#trap read debug

if [ -f path.sh ]; then . ./path.sh; fi

nj=$1
data=$2
trans=$3
nnet=$4
alpha=$5
beta=$6
dir=$7

mkdir -p $dir || exit 1;

feats_scp=$data/feats.scp
cmvn=$data/cmvn.scp

# check files exist
required="$trans $nnet $feats_scp $cmvn"
for f in $required; do
  if [ ! -f $f ]; then
    echo "[error] make_fbank_pitch.sh: no such file $f"
    exit 1;
  fi
done

### queued jobs on the CPU, but BE CAREFUL WITH SWAP memory!!!
fscp=$data/fbank_pitch.JOB.scp # JOB is placeholder for number of chunk
cmvn_opts="apply-cmvn --print-args=false --norm-vars=true scp:$cmvn ark:- ark:-"
delta_opts="add-deltas --delta-order=2 ark:- ark:-"
feats="ark:copy-feats scp:$fscp ark:- | $cmvn_opts | $delta_opts |"

# Run the data forward pass in the parallel queue on the CPU
use_gpu=no
num_threads=3
minibatch_size=128
# TODO check if the objective function matter
obj=mif-uvz
loops=$(($nj / $num_threads - 1))
for i in `seq 0 $loops`; do
	st=$(($i * $num_threads + 1))
	end=$((($i + 1) * $num_threads))
	echo "loop jobs: $st - $end"
	run.pl JOB=$st:$end $dir/log/decode.JOB.log \
	  nnet-forward --use-gpu=$use_gpu --cross-validate=true \
      --minibatch-size=$minibatch_size \
      --objective-function=$obj \
      --multiplicative-param=$alpha --additive-param=$beta \
	  --feature-transform=$trans \
      "$nnet" "$feats"  "ark,t:$dir/scores.JOB.txt" || exit 1;
done

if [ $(($loops * $num_threads)) -ne $nj ]; then
	st=$((($loops + 1) * $num_threads + 1))
	echo "Ending jobs: $st - $nj"
	run.pl JOB=$st:$nj $dir/log/decode.JOB.log \
	  nnet-forward --use-gpu=$use_gpu --cross-validate=true \
      --minibatch-size=$minibatch_size \
      --objective-function=$obj \
      --multiplicative-param=$alpha --additive-param=$beta \
	  --feature-transform=$trans \
      "$nnet" "$feats"  "ark,t:$dir/scores.JOB.txt" || exit 1;
fi
#############

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

echo "[info] attribute scores are successfully extracted";
