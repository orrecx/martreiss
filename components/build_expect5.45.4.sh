#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
	cp -v configure{,.orig}
	sed 's:/usr/local/bin:/bin:' configure.orig > configure	
	./configure --prefix=$TOOLS_SLINK \
	        --with-tcl=$TOOLS_SLINK/lib \
            --with-tclinclude=$TOOLS_SLINK/include
	make
	if [ "$1" == "--test" ]; then
		make test
		ERR=$?
	fi
	[ $ERR -eq 0 ] && make SCRIPTS="" install || echo "[ERROR]: build failed"
	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="expect5.45.4.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build #--test #ignore test for now
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
