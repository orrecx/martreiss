#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	sed -i s/mawk// configure
	./configure --prefix=$TOOLS_SLINK  \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite	
	make
	make install
    ln -s libncursesw.so /tools/lib/libncurses.so
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="ncurses-6.2.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build

cd $SRC
rm -v -rf $TG

exit $ERROR
