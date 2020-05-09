#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build ()
{
	sed -i '/MV.*old/d' Makefile.in
	sed -i '/{OLDSUFF}/c:' support/shlib-install
	./configure --prefix=/usr    \
	            --disable-static \
	            --docdir=/usr/share/doc/readline-8.0

	make SHLIB_LIBS="-L/tools/lib -lncursesw"
	make SHLIB_LIBS="-L/tools/lib -lncursesw" install

	mv -v /usr/lib/lib{readline,history}.so.* /lib
	chmod -v u+w /lib/lib{readline,history}.so.*
	ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
	ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so

	install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.0
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="readline-8.0.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build_ext

cd $SRC
rm -v -rf $TG

exit $ERROR
