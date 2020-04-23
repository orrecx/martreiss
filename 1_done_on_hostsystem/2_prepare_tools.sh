#!/bin/bash
echo "---------------- $0 ---------------------"
[ $(id --user) -ne 0 ] && echo "[ERROR]: only root is allowed to run this script. use sudo" && exit 1
pushd $(pwd)
cd /bin
ln -v -s -f /usr/bin/bash sh
popd

apt-get install -y gawk
apt-get install -y texinfo
apt-get install -y bison
