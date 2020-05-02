#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    ./configure --disable-shared
    make
    cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /$TOOLS_SLINK/bin
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

_build
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
