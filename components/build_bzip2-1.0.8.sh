#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    make -f Makefile-libbz2_so
    make clean
    make
    make PREFIX=$TOOLS_SLINK install
    cp -v bzip2-shared $TOOLS_SLINK/bin/bzip2
    cp -av libbz2.so* $TOOLS_SLINK/lib
    ln -sv libbz2.so.1.0 $TOOLS_SLINK/lib/libbz2.so    
}

function _build_ext ()
{
    patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
    sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
    sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
    make -f Makefile-libbz2_so
    make clean
    make
    make PREFIX=/usr install

    cp -v bzip2-shared /bin/bzip2
    cp -av libbz2.so* /lib
    ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
    rm -v /usr/bin/{bunzip2,bzcat,bzip2}
    ln -sv bzip2 /bin/bunzip2
    ln -sv bzip2 /bin/bzcat
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="bzip2-1.0.8.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

case "$1" in
	--ext)
	_build_ext
	;;
	*)
	_build
	;;
esac

cd $SRC
rm -v -rf $TG

exit $ERROR
