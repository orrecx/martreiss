#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    PAGE=A4 ./configure --prefix=/usr
    make -j1
    make install
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="groff-1.22.4.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build

cd $SRC
rm -v -rf $TG

exit $ERROR
