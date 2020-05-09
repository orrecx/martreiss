#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    sh Configure -des -Dprefix=$TOOLS_SLINK -Dlibs=-lm -Uloclibpth -Ulocincpth
    make
    cp -v perl cpan/podlators/scripts/pod2man $TOOLS_SLINK/bin
    mkdir -pv $TOOLS_SLINK/lib/perl5/5.30.1
    cp -Rv lib/* $TOOLS_SLINK/lib/perl5/5.30.1
}

function _build_ext ()
{
    local ERR=0
    echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
    export BUILD_ZLIB=False
    export BUILD_BZIP2=0
    sh Configure -des -Dprefix=/usr                 \
                      -Dvendorprefix=/usr           \
                      -Dman1dir=/usr/share/man/man1 \
                      -Dman3dir=/usr/share/man/man3 \
                      -Dpager="/usr/bin/less -isR"  \
                      -Duseshrplib                  \
                      -Dusethreads
    make
	if [ "$1" == "--test" ]; then
		make test
		ERR=$?
		[ $ERR -ne 0 ] && echo "[ERROR]: test failed"
	fi
    make install
    unset BUILD_ZLIB BUILD_BZIP2				  
    return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="perl-5.30.1.tar.xz"

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
