#!/usr/bin/env bash
set -euo pipefail

docker run -d --restart=unless-stopped \
  -p 80:80 -p 443:443 \
  --privileged \
  rancher/rancher:latest

docker logs $(docker ps | grep rancher | awk '{print $1}') 2>&1 | grep "Bootstrap Password:"