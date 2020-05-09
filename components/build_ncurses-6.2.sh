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

function _build_ext () 
{
    sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
    ./configure --prefix=/usr           \
                --mandir=/usr/share/man \
                --with-shared           \
                --without-debug         \
                --without-normal        \
                --enable-pc-files       \
                --enable-widec
    make
    make install
    mv -v /usr/lib/libncursesw.so.6* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so
    for lib in ncurses form panel menu ; do
        rm -vf                    /usr/lib/lib${lib}.so
        echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
        ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
    done
    rm -vf                     /usr/lib/libcursesw.so
    echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
    ln -sfv libncurses.so      /usr/lib/libcurses.so
    mkdir -v       /usr/share/doc/ncurses-6.2
    cp -v -R doc/* /usr/share/doc/ncurses-6.2
    make distclean
    ./configure --prefix=/usr    \
                --with-shared    \
                --without-normal \
                --without-debug  \
                --without-cxx-binding \
                --with-abi-version=5 
    make sources libs
    cp -av lib/lib*.so.5* /usr/lib
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
