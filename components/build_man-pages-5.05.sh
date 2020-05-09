#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	make install
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="man-pages-5.05.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build

cd $SRC
rm -v -rf $TG

exit $ERROR
