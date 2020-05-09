#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
	ABI=32 ./configure ...
	cp -v configfsf.guess config.guess
	cp -v configfsf.sub   config.sub

	./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.2.0
	make
	make html
				
	if [ "$1" == "--test" ]; then
		make check 2>&1 | tee gmp-check-log
		ERR=$?
		awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log		
	fi

	[ $ERR -ne 0 ] && echo "[ERROR]: test failed"
	make install
	make install-html

	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="gmp-6.2.0.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build --test
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
