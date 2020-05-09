#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
	./configure --prefix=/usr
	make
 	if [ "$1" == "--test" ]; then
		make check
		ERR=$?
		[ $ERR -ne 0 ] && echo "[ERROR]: test failed"
	fi
	make install
	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="libpipeline-1.5.2.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
