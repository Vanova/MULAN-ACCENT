#!/bin/bash

if [ -f path.sh ]; then . ./path.sh; fi

data=$1
cmvndir=$2
logdir=$data/log

mkdir -p $cmvndir || exit 1;
mkdir -p $logdir || exit 1;

! compute-cmvn-stats scp:$data/fbank_pitch.scp ark,scp,t:$cmvndir/cmvn.ark,$cmvndir/cmvn.scp \
    2> $logdir/cmvn.log && echo "Error computing CMVN stats" && exit 1;

echo "Succeeded creating CMVN stats for $data/fbank_pitch.scp"
