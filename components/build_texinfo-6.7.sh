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
    ./configure --prefix=/usr --disable-static
    make
 	if [ "$1" == "--test" ]; then
		make check
		ERR=$?
		[ $ERR -ne 0 ] && echo "[ERROR]: test failed"
	fi
    make install
    make TEXMF=/usr/share/texmf install-tex
    pushd /usr/share/info
    rm -v dir
    for f in *
      do install-info $f dir 2>/dev/null
    done
    popd
	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="texinfo-6.7.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

case "$1" in
	--ext)
	_build_ext --test
	ERROR=$?
	;;
	*)
	_build --test
	ERROR=$?
	;;
esac

cd $SRC
rm -v -rf $TG

exit $ERROR
