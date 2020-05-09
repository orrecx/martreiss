#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    patch -Np1 -i ../sysvinit-2.96-consolidated-1.patch
    make
    make install
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="sysvinit-2.96.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build

cd $SRC
rm -v -rf $TG

exit $ERROR
