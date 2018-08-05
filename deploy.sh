#!/bin/bash

set -u
set -e


FFMPEG_NAME=ffmpeg_g$(git rev-parse --short HEAD)_d$(date +%s)
mv ffmpeg_bin/ffmpeg $FFMPEG_NAME

mkdir -p ~/.ssh/
echo "$DEPLOY_SSH_KEY" > ~/.ssh/id_rsa
scp -P $DEPLOY_SSH_PORT $FFMPEG_NAME $DEPLOY_SSH_USER@$DEPLOY_HOSTNAME:$DEPLOY_PATH