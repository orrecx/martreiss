#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    sed -i '/def add_multiarch_paths/a \        return' setup.py
    ./configure --prefix=$TOOLS_SLINK --without-ensurepip
    make
    make install
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="Python-3.8.1.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
