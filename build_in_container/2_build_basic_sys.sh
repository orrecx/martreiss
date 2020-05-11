#!/bin/bash
echo "####################################################"  | tee    $LFS/results/build.log
echo "#         BUILD BASIC_SYS IN DOCKER CONTAINER      #"  | tee -a $LFS/results/build.log
echo "####################################################"  | tee -a $LFS/results/build.log
cd "$( dirname $(realpath $0))"

hash -r
set +h

DOCKER_CONTEXT=1
export DOCKER_CONTEXT

source ../common/config.sh
source ../common/utils.sh

LC_ALL=POSIX
PATH="$PATH:/tools/$(uname -m)-pc-linux-gnu/bin"
export LC_ALL PATH

../3_base_sys/main.sh

../4_configure_basic_sys/main.sh