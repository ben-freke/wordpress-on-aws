#!/bin/bash
yum update -y
yum install docker -y
yum install git -y
systemctl enable docker
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.283.3.tar.gz -L https://github.com/actions/runner/releases/download/v2.283.3/actions-runner-linux-x64-2.283.3.tar.gz
echo "09aa49b96a8cbe75878dfcdc4f6d313e430d9f92b1f4625116b117a21caaba89  actions-runner-linux-x64-2.283.3.tar.gz" | shasum -a 256 -c
tar xzf ./actions-runner-linux-x64-2.283.3.tar.gz
./config.sh --url https://github.com/ben-freke/wordpress-infrastructure --token AB2EWTAB5O77VQ2TJXFIVQDBOFYPK
./run.sh