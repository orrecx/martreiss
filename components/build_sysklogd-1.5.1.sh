#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
	./configure --prefix=$TOOLS_SLINK
	make
	if [ "$1" == "--test" ]; then
		make check
		ERR=$?
	fi
	[ $ERR -eq 0 ] && make install || echo "[ERROR]: build failed"
	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
SRC=$SOURCES_DIR
COMP="sysklogd-1.5.1.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR