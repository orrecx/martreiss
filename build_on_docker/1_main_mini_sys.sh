#!/bin/bash
echo "####################################################"
echo "#             BUILD MINI_SYS ON DOCKER             #"
echo "####################################################"

[ -n "$LFS" ] && export LFS="/lfs"
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:$PATH
export LC_ALL LFS_TGT PATH

CD=$(realpath $0)
CD=$(dirname $CD)
cd $CD

../1_prepare_build_env/main.sh --docker | tee $LFS/results/build.log

../2_build_mini_sys/main.sh --docker | tee -a $LFS/results/build.log
