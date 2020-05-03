#!/bin/bash
echo "####################################################"
echo "#         BUILD TEMP_SYS IN DOCKER CONTAINER       #"
echo "####################################################"
cd "$( dirname $(realpath $0))"

hash -r
set +h

DOCKER_CONTEXT=1
export DOCKER_CONTEXT

source ../common/config.sh
source ../common/utils.sh

LC_ALL=POSIX
PATH="$TOOLS_SLINK/bin:/bin:/usr/bin"
export LC_ALL PATH

../1_prepare_build_env/main.sh --docker | tee $LFS/results/build.log

../2_tmp_sys/main.sh --docker | tee -a $LFS/results/build.log
