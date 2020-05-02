#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
	cd unix
	./configure --prefix=$TOOLS_SLINK
	make
	if [ "$1" == "--test" ]; then
		TZ=UTC make test
		ERR=$?
	fi

	if [ $ERR -eq 0 ]; then 
		make install
		chmod -v u+w /tools/lib/libtcl8.6.so
		make install-private-headers
		ln -sv tclsh8.6 /tools/bin/tclsh
	fi
	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="tcl8.6.10-src.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build #--test #ignore testing for now
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
