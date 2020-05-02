#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
	./configure --prefix=$TOOLS_SLINK --without-bash-malloc
	make
	if [ "$1" == "--test" ]; then
		make test
		ERR=$?
	fi

	if [ $ERR -eq 0 ]; then 
		make install
		ln -sv bash /tools/bin/sh
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
COMP="bash-5.0.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build #--test #ignore for now
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
