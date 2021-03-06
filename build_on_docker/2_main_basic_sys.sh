#!/bin/bash

function _archive ()
{
    tar --exclude="/lfs"        \
        --exclude="/tools"      \
        --exclude="/sources"    \
        --exclude="/workspace"  \
        -cf /lfs/results/matrissys.tar /*

    gzip /lfs/results/matrissys.tar
}

echo "####################################################"
echo "#             BUILD BASIC_SYS ON DOCKER            #"
echo "####################################################"

LC_ALL=POSIX
PATH="$PATH:/tools/$(uname -m)-pc-linux-gnu/bin"
export LC_ALL PATH

CD=$(realpath $0)
CD=$(dirname $CD)
cd $CD

./main.sh --docker
#_archive

#rm -rf /workspace /tools /sources &> /dev/null
