#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
    patch -Np1 -i ../kbd-2.2.0-backspace-1.patch
    sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
    sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
    PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock
    make
 	if [ "$1" == "--test" ]; then
		make check
		ERR=$?
		[ $ERR -ne 0 ] && echo "[ERROR]: test failed"
	fi
    make install
    mkdir -v       /usr/share/doc/kbd-2.2.0
    cp -R -v docs/doc/* /usr/share/doc/kbd-2.2.0
	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="kbd-2.2.0.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build --test
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
