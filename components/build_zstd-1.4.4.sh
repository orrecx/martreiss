#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    make
    make prefix=/usr install
    rm -v /usr/lib/libzstd.a
    mv -v /usr/lib/libzstd.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libzstd.so) /usr/lib/libzstd.so
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="zstd-1.4.4.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build

cd $SRC
rm -v -rf $TG

exit $ERROR
