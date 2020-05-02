#!/bin/bash

ERROR=0

function _build () 
{
	local ERR=0
	./configure --prefix=/usr
	make
	if [ "$1" == "--test" ]; then
		make check
		ERR=$?
	fi
	[ $ERR -eq 0 ] && make install || echo "[ERROR]: build failed"
	return $ERR
}

source ../common/utils.sh
#----------------------------------------

cd $SRC
TG=$(extract   gzip-1.10.tar.xz )
cd $TG

_build
ERROR=$?

cd $SRC
rm -v -rf $TG
exit $ERROR
