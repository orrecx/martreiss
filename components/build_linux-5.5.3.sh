#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    make mrproper
	if [ "$1" == "--headers" ]; then
    	make headers
    	cp -rv usr/include/* /tools/include
	fi
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="linux-5.5.3.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build $1
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
