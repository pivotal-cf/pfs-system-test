#!/bin/bash

eksctl_version="0.1.15"
eksctl_dir=`mktemp -d eksctl.XXXX`

curl -s -L "https://github.com/weaveworks/eksctl/releases/download/${eksctl_version}/eksctl_Linux_amd64.tar.gz" \
  | tar xz -C $eksctl_dir
chmod +x $eksctl_dir/eksctl
sudo mv $eksctl_dir/eksctl /usr/local/bin

rm -rf $eksctl_dir
