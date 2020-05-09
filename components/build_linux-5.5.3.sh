#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _headers () 
{
    make mrproper
   	make headers
	if [ "$1" == "optimized" ]; then
	    find usr/include -name '.*' -delete
	    rm usr/include/Makefile
	fi
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
	--headers_optimized)
	_headers "optimized"
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
