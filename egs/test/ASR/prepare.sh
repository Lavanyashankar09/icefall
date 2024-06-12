#!/usr/bin/env bash

export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

set -eou pipefail

stage=-1
stop_stage=100

dl_dir=$PWD/download

lang_dir=data/lang_phone
lm_dir=data/lm

. shared/parse_options.sh || exit 1

mkdir -p $lang_dir
mkdir -p $lm_dir

log() {
  # This function is from espnet
  local fname=${BASH_SOURCE[1]##*/}
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') (${fname}:${BASH_LINENO[0]}:${FUNCNAME[1]}) $*"
}

log "dl_dir: $dl_dir"

if [ $stage -le 0 ] && [ $stop_stage -ge 0 ]; then
  log "Stage 0: Download data"
  mkdir -p $dl_dir

  if [ ! -f $dl_dir/waves_test/.completed ]; then
    lhotse download test $dl_dir
  fi
fi

if [ $stage -le 1 ] && [ $stop_stage -ge 1 ]; then
  log "Stage 1: Prepare yesno manifest"
  mkdir -p data/manifests
  lhotse prepare test $dl_dir/waves_yesno data/manifests
fi

if [ $stage -le 2 ] && [ $stop_stage -ge 2 ]; then
  log "Stage 2: Compute fbank for yesno"
  mkdir -p data/fbank
  ./local/compute_fbank_yesno.py
fi
