#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
    mkdir -v build
    cd       build
    ../configure                             \
          --prefix=/tools                    \
          --host=$LFS_TGT                    \
          --build=$(../scripts/config.guess) \
          --enable-kernel=3.2                \
          --with-headers=/tools/include

    make
    make install

	if [ "$1" == "--test" ]; then
	    #sanitiy check: check if compiling and linking works as expected
	    mkdir sanity_test
	    cd sanitiy_test
	    echo "#include <stdio.h>" > dummy.c
	    echo 'int main(){ return 1;}' >> dummy.c
	    $LFS_TGT-gcc dummy.c
	    readelf -l a.out | grep ': /tools'
	    local ERR=$?
	    [ $ERR -ne 0 ] && echo "[ERROR]: tool chain does not work properly"
	fi
	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="glibc-2.31.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
