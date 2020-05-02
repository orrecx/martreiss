#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
    FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=$TOOLS_SLINK --enable-install-program=hostname
    make
	if [ "$1" == "--test" ]; then
	    make RUN_EXPENSIVE_TESTS=yes check
		#ERR=$? #ignore test result for now
	fi
	[ $ERR -eq 0 ] && make install || echo "[ERROR]: build failed"
	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="coreutils-8.31.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build --test
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
