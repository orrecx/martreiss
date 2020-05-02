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

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="perl-5.30.1.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
