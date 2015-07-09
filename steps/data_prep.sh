#!/bin/bash

ls -1 data/wav > data/waves.list
local/create_wav_scp.pl data/wav data/waves.list > data/waves.scp

if [ ! -f data/waves.list ]; then
  echo "[error] there are no waves in data/wav/";  
fi

echo "$0: data prepared"
