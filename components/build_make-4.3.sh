#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
	./configure --prefix=$TOOLS_SLINK "--without-guile"
	make
	if [ "$1" == "--test" ]; then
		make check
		ERR=$?
	fi
	[ $ERR -eq 0 ] && make install || echo "[ERROR]: build failed"
	return $ERR
}

function _build_ext ()
{
	local ERR=0
    ./configure --prefix=/usr
    make
 	if [ "$1" == "--test" ]; then
	    make PERL5LIB=$PWD/tests/ check
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
COMP="make-4.3.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

case "$1" in
	--ext)
	_build_ext --test
	ERROR=$?
	;;
	*)
	_build --test
	ERROR=$?
	;;
esac

cd $SRC
rm -v -rf $TG

exit $ERROR
