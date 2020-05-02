#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _headers () 
{
    make mrproper
   	make headers
   	cp -rv usr/include/* /tools/include
}

function _build ()
{
	echo "Nothing to do for now"
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="linux-5.5.3.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

case "$1" in
	--headers)
	_headers
	;;
	--kernel)
	_build
	;;
	*)
	echo "[ERROR]: unknown argument"
	ERROR=1
	;;
esac

cd $SRC
rm -v -rf $TG

exit $ERROR
