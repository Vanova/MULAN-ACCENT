#export KALDI_ROOT=`pwd`/../../..
export KALDI_ROOT=/usr/local/src/kaldi-trunk;
#export KALDI_ROOT=/home/vano/DevTools/kaldi-trunk;

export PATH=$PWD/utils/:$KALDI_ROOT/src/bin:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/tools/irstlm/bin/:$KALDI_ROOT/src/fstbin/:$KALDI_ROOT/src/gmmbin/:$KALDI_ROOT/src/featbin/:$KALDI_ROOT/src/lm/:$KALDI_ROOT/src/sgmmbin/:$KALDI_ROOT/src/sgmm2bin/:$KALDI_ROOT/src/fgmmbin/:$KALDI_ROOT/src/latbin/:$KALDI_ROOT/src/nnetbin:$KALDI_ROOT/src/nnet2bin/:$KALDI_ROOT/src/kwsbin:$PWD:$PATH
export LC_ALL=C
export IRSTLM=$KALDI_ROOT/tools/irstlm


# CUDA folders
export LD_LIBRARY_PATH=/usr/local/cuda-5.0/lib64:/lib:/usr/lib:/usr/local/lib;
export PATH=/usr/local/cuda-5.0/bin:$PATH;


#export LD_LIBRARY_PATH=/usr/local/cuda-6.5/lib64:/lib:/usr/lib:/usr/local/lib;
#export PATH=/usr/local/cuda-6.5/bin:$PATH;


