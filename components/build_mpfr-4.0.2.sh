#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
	./configure --prefix=/usr        \
	            --disable-static     \
	            --enable-thread-safe \
	            --docdir=/usr/share/doc/mpfr-4.0.2
	make
	make html

	if [ "$1" == "--test" ]; then
		make check
		ERR=$?
	fi

	[ $ERR -ne 0 ] && echo "[ERROR]: test failed"
	make install
	make install-html

	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="mpfr-4.0.2.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build --test
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
