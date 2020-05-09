#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
    ./configure --prefix=/usr    \
                --disable-static \
                --enable-libgdbm-compat
    make
    make check
    local ERR=$?
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
COMP="gdbm-1.18.1.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build --test
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
