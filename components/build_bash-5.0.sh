#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
	./configure --prefix=$TOOLS_SLINK --without-bash-malloc
	make
	if [ "$1" == "--test" ]; then
		make test
		ERR=$?
	fi

	if [ $ERR -eq 0 ]; then 
		make install
		ln -sv bash /tools/bin/sh
	else
		echo "[ERROR]: build failed"
	fi
	return $ERR
}

function _build_ext ()
{
	local ERR=0
    patch -Np1 -i ../bash-5.0-upstream_fixes-1.patch
    ./configure --prefix=/usr                    \
                --docdir=/usr/share/doc/bash-5.0 \
                --without-bash-malloc            \
                --with-installed-readline
    make
 	if [ "$1" == "--test" ]; then
	    chown -Rv nobody .
    	su nobody -s /bin/bash -c "PATH=$PATH HOME=/home make tests"
		ERR=$?
		[ $ERR -ne 0 ] && echo "[ERROR]: test failed"
	fi
	make install
	mv -vf /usr/bin/bash /bin
	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="bash-5.0.tar.gz"

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
