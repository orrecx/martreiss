#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
	sed -i '/install.*STA...LIBNAME/d' libcap/Makefile
	make lib=lib

	if [ "$1" == "--test" ]; then
		make test
		ERR=$?
		[ $ERR -ne 0 ] && echo "[ERROR]: test failed"
	fi

	make lib=lib install
	chmod -v 755 /lib/libcap.so.2.31
	
	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="libcap-2.31.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build --test
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
