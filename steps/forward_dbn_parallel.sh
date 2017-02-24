#!/bin/bash
# set -x
#trap read debug

if [ -f path.sh ]; then . ./path.sh; fi

nj=$1
data=$2
trans=$3
nnet=$4
dir=$5

mkdir -p $dir || exit 1;

feats_scp=$data/feats.scp

# check files exist
required="$trans $nnet $feats_scp"
for f in $required; do
  if [ ! -f $f ]; then
    echo "[error] make_fbank.sh: no such file $f"
    exit 1;
  fi
done

### queued jobs on the CPU, but BE CAREFUL WITH SWAP memory!!!
fscp=$data/fbank.JOB.scp # JOB is placeholder for number of chunk
delta_opts="add-deltas --delta-order=2 ark:- ark:-"
feats="ark:copy-feats scp:$fscp ark:- | $delta_opts |"

# Run the data forward pass in the parallel queue on the CPU
# nnet_forward_opts="--no-softmax=true --prior-scale=1.0"
use_gpu=no
num_threads=20 # TODO: fix number according to the number of threads of PC
loops=$(($nj / $num_threads))
for i in `seq 1 $loops`; do
	st=$((($i - 1) * $num_threads + 1))
	end=$(($i * $num_threads))
	echo "loop jobs: $st - $end"
	run.pl JOB=$st:$end $dir/log/decode.JOB.log \
	nnet-forward $nnet_forward_opts --feature-transform=$trans \
	 --use-gpu=$use_gpu "$nnet" "$feats"  "ark,t:$dir/scores.JOB.txt" || exit 1;
done

if [ $(($loops * $num_threads)) -ne $nj ]; then
	st=$(($loops * $num_threads + 1))
	echo "Ending jobs: $st - $nj"
	run.pl JOB=$st:$nj $dir/log/decode.JOB.log \
		nnet-forward $nnet_forward_opts --feature-transform=$trans \
		 --use-gpu=$use_gpu "$nnet" "$feats"  "ark,t:$dir/scores.JOB.txt" || exit 1;
fi
#############

# check number of extracted score files
for i in `seq 1 $nj`; do
	fb="$data/fbank.$i.scp"
	scores="$dir/scores.$i.txt"
	nf=`cat $fb | wc -l`
	nu=`grep -o "\[" $scores | wc -l`

	if [ $nf -ne $nu ]; then
	  echo "$0: it seems not all of the feature files were successfully processed ($nf != $nu):"
	  echo "compare $fb vs $scores"
	  exit 1;
	# else
		# echo "scores have been checked"
	fi
done

echo "[info] attribute scores are successfully extracted";
