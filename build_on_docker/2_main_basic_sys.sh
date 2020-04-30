#!/bin/bash
echo "####################################################"
echo "#             BUILD BASIC_SYS ON DOCKER             #"
echo "####################################################"

LC_ALL=POSIX
PATH="$PATH:/tools/$(uname -m)-pc-linux-gnu/bin"
WRK="/workspace"
export LC_ALL PATH WRK

CD=$(realpath $0)
CD=$(dirname $CD)
cd $CD

./main.sh --docker

tar --exclude="/lfs"        \
    --exclude="/tools"      \
    --exclude="/sources"    \
    --exclude="/workspace"  \
    -cf /lfs/results/matrissys.tar /*

gzip /lfs/results/matrissys.tar

#rm -rf /workspace /tools /sources &> /dev/null
