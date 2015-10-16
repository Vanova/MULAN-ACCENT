#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi

data=$1
cmvndir=$2
logdir=$data/log

mkdir -p $cmvndir || exit 1;
mkdir -p $logdir || exit 1;

! compute-cmvn-stats scp:$data/feats.scp ark,scp,t:$cmvndir/cmvn.ark,$cmvndir/cmvn.scp \
    2> $logdir/cmvn.log && echo "$0: error computing CMVN stats" && exit 1;

nc=`cat $cmvndir/cmvn.scp | wc -l` 
nu=`cat $data/feats.scp | wc -l` 
if [ $nc -ne $nu ]; then
  echo "$0: warning: it seems not all of the audio files got cmvn stats ($nc != $nu);"
  [ $nc -eq 0 ] && exit 1;
fi


echo "Succeeded creating CMVN stats for $data/fbank_pitch.scp"
