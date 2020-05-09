#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
    sed -i 's/union wait/int/' syslogd.c

    make
    make BINDIR=/sbin install
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="sysklogd-1.5.1.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build

cd $SRC
rm -v -rf $TG

exit $ERROR
