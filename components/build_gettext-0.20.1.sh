#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    ./configure --disable-shared
    make
    cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /$TOOLS_SLINK/bin
}

function _build_ext ()
{
    local ERR=0
    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/gettext-0.20.1
    make
	if [ "$1" == "--test" ]; then
		make check
		ERR=$?
		[ $ERR -ne 0 ] && echo "[ERROR]: test failed"
	fi
    make install
    chmod -v 0755 /usr/lib/preloadable_libintl.so
    return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="gettext-0.20.1.tar.xz"

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
