#!/bin/bash

# set -x;
# trap read debug

# Begin config
fbank_config=conf/fbank_cnn.conf
pitch_config=conf/pitch_cnn.conf
paste_length_tolerance=2
compress=true
# End config

echo "$0 $@"  # Print the command line for logging

if [ -f path.sh ]; then . ./path.sh; fi

nj=$1
data=$2
fbankdir=$3
logdir=$fbankdir/log

mkdir -p $fbankdir || exit 1;
mkdir -p $logdir || exit 1;

# check wav lists and configuration exists
scp=$data/waves.scp

required="$scp $fbank_config $pitch_config"
for f in $required; do
  if [ ! -f $f ]; then
    echo "make_fbank_pitch.sh: no such file $f" && exit 1;
  fi
done

# split data for paralleling
echo "$0: split $scp on nj = $nj."
split_scps=""
for n in $(seq $nj); do
  split_scps="$split_scps $logdir/wav.$n.scp"
done
utils/split_scp.pl $scp $split_scps || exit 1;

# run parallel fbank feature extraction
fbank_feats="ark:compute-fbank-feats --verbose=2 --config=$fbank_config scp,p:$logdir/wav.JOB.scp ark:- |"
pitch_feats="ark,s,cs:compute-kaldi-pitch-feats --verbose=2 --config=$pitch_config scp,p:$logdir/wav.JOB.scp ark:- | process-kaldi-pitch-feats ark:- ark:- |"

run.pl JOB=1:$nj $logdir/make_fbank_pitch.JOB.log \
    paste-feats --length-tolerance=$paste_length_tolerance "$fbank_feats" "$pitch_feats" ark:- \| \
    copy-feats --compress=$compress ark:- \
      ark,scp:$fbankdir/fbank_pitch.JOB.ark,$fbankdir/fbank_pitch.JOB.scp \
      || exit 1;

if [ -f $logdir/.error ]; then
  echo "Error producing fbank & pitch features for $data:"
  tail $logdir/make_fbank_pitch.1.log
  exit 1;
fi

# concatenate the .scp files together.
for n in $(seq $nj); do
  cat $fbankdir/fbank_pitch.$n.scp || exit 1;
done > $fbankdir/feats.scp

rm $logdir/wav.*.scp  $logdir/segments.* 2>/dev/null

nf=`cat $fbankdir/feats.scp | wc -l` 
nu=`cat $scp | wc -l` 
if [ $nf -ne $nu ]; then
  echo "It seems not all of the feature files were successfully processed ($nf != $nu):"
  echo "compare $fbankdir/feats.scp vs $scp"
  exit 1;
fi

echo "Succeeded creating filterbank & pitch features for $scp"
