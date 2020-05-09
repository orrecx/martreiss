#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    python3 setup.py build
    python3 setup.py install --root=dest
    cp -rv dest/* /
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="meson-0.53.1.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build

cd $SRC
rm -v -rf $TG

exit $ERROR
