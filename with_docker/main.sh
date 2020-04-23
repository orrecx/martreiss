#!/usr/bin/bash
[ -z "$LFS" ] && LFS="/lfs" && export LFS
[ ! -d "$LFS" ] && mkdir -v "$LFS"

ERROR=0

echo "================ MAIN ================"
CD=$(realpath $0)
CD=$(dirname $CD)
cd $CD
./prepare.sh
ERROR=$?
if [ $ERROR -eq 0 ]; then

    LC_ALL=POSIX
    LFS_TGT=$(uname -m)-lfs-linux-gnu
    PATH=/tools/bin:/bin:/usr/bin
    export LC_ALL LFS_TGT PATH

    ./build_mini_lfs.sh
    ERROR=$?
fi
