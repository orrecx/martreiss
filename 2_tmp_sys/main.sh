#!/bin/bash
cd "$( dirname $(realpath $0))"

#---------------------------------------------
function delete_unecessary_files ()
{
    echo "Don't do this because it will damage the compile environment"
    
    #echo "function delete_unecessary_files..."
    #find $LFS/tools/{lib,libexec} -name \*.la -delete 
    #rm -v -rf $LFS/tools/{,share}/{info,man,doc}
}

function archive_tmp_sys ()
{
    echo "archiving tmp_sys to $LFS/results/tools.tar.gz"
    cd $LFS
    tar cf  $LFS/results/tools.tar tools
    gzip -v $LFS/results/tools.tar
    cd -
}

function archive_sources ()
{    
    if [ ! -e "$(pwd)/../$BACKYARD/sources.tar.gz" ]; then
        echo "archiving sources to $LFS/results/sources.tar.gz"
        cd $LFS
        tar cf  $LFS/results/sources.tar sources
        gzip -v $LFS/results/sources.tar
        cd -
    else
        echo "archiving sources not needed"
    fi
}

#-----------------------------------------------
[ "x$DOCKER_CONTEXT" = "x" ] && DOCKER_CONTEXT=0
ERROR=0

case "$1" in
--docker) DOCKER_CONTEXT=1 ;;
esac

export DOCKER_CONTEXT
source ../common/config.sh
source ../common/utils.sh

s_start $0
START_TIME=$?

if [ $DOCKER_CONTEXT -eq 0 ]; then
    U="lfs"
    id -u $U
    [ $? -ne 0 ] && echo "[ERROR]: a user $U is required" && exit 1
    [ "$(id -u)" -ne $(id -u $U) ] && echo "[ERROR]: run this script as user $U" && exit 2
fi

if [ ! -d "$LFS" ]; then
    echo "[ERROR]: directory $LFS does not exist yet"
    exit 3
fi

echo "================ MAIN: CONSTRUCT INITIAL SYSTEM ================"
if [ $DOCKER_CONTEXT -eq 0 ]; then
    export MAKEFLAGS='-j 2'
    env -i DOCKER_CONTEXT=$DOCKER_CONTEXT \
    HOME=$HOME \
    TERM=$TERM \
    LFS=$LFS \
    LFS_TGT=$LFS_TGT \
    PATH=$PATH \
    'PS1=(limited)\u:\w\$' \
    /bin/bash -c ./build.sh
    ERROR=$?
else
    ./build.sh
    ERROR=$?
fi

if [ $ERROR -eq 0 ]; then
    #delete_unecessary_files
    archive_tmp_sys
else
    echo "[ERROR]: build failed"
fi

archive_sources

s_end $0
END_TIME=$?
s_duration $0 $START_TIME $END_TIME 

exit $ERROR