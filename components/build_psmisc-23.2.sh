#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	./configure --prefix=$TOOLS_SLINK
	make
	make install
	mv -v /usr/bin/fuser   /bin
	mv -v /usr/bin/killall /bin	
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="psmisc-23.2.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build

cd $SRC
rm -v -rf $TG

exit $ERROR
