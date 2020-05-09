#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
	./configure --prefix=$TOOLS_SLINK
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
    sed -i 's/usr/tools/'                 build-aux/help2man
    sed -i 's/testsuite.panic-tests.sh//' Makefile.in
    ./configure --prefix=/usr --bindir=/bin
    make
    make html
	if [ "$1" == "--test" ]; then
		make check
		ERR=$?
		[ $ERR -ne 0 ] && echo "[ERROR]: test failed"
	fi

    make install
    install -d -m755           /usr/share/doc/sed-4.8
    install -m644 doc/sed.html /usr/share/doc/sed-4.8

    return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="sed-4.8.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

case "$1" in
    --ext)
    _build_ext --test
	ERROR=$?
    ;;
    *)
    _build
	ERROR=$?
    ;;
esac

cd $SRC
rm -v -rf $TG

exit $ERROR
