#!/bin/bash

wavdir=$1

wavlist=data/waves.list
scp=data/waves.scp

ls -1 $wavdir > $wavlist

if [ ! -f $wavlist ]; then
  echo "[error] there are no waves in $wavdir" && exit 1;  
fi

# iterate waves list and prepare kaldi scp: [wavID] [file full path]
while read line; do
	fn=$wavdir/$line  
  [ ! -f "$fn" ] && echo "[error] no such wav file..." && exit 1;
  echo ${line%.*} $fn
done < $wavlist > $scp;

echo "$0: data prepared successfully"
