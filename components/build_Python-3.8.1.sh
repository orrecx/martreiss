#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    sed -i '/def add_multiarch_paths/a \        return' setup.py
    ./configure --prefix=$TOOLS_SLINK --without-ensurepip
    make
    make install
}

function _build_ext ()
{
    ./configure --prefix=/usr       \
                --enable-shared     \
                --with-system-expat \
                --with-system-ffi   \
                --with-ensurepip=yes
    make
    make install
    chmod -v 755 /usr/lib/libpython3.8.so
    chmod -v 755 /usr/lib/libpython3.so
    ln -svf pip3.8 /usr/bin/pip3			

    install -v -dm755 /usr/share/doc/python-3.8.1/html 

    tar --strip-components=1  \
        --no-same-owner       \
        --no-same-permissions \
        -C /usr/share/doc/python-3.8.1/html \
        -xvf ../python-3.8.1-docs-html.tar.bz2
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="Python-3.8.1.tar.xz"

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
