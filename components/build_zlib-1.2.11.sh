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

	if [ $ERR -eq 0 ]; then
		make install
		mv -v /usr/lib/libz.so.* /lib
		ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so
	else
		echo "[ERROR]: build failed"
	fi
	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="zlib-1.2.11.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
