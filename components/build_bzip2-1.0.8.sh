#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    make -f Makefile-libbz2_so
    make clean
    make
    make PREFIX=$TOOLS_SLINK install
    cp -v bzip2-shared $TOOLS_SLINK/bin/bzip2
    cp -av libbz2.so* $TOOLS_SLINK/lib
    ln -sv libbz2.so.1.0 $TOOLS_SLINK/lib/libbz2.so    
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="bzip2-1.0.8.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
