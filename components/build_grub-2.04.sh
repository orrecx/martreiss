#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    ./configure --prefix=/usr          \
                --sbindir=/sbin        \
                --sysconfdir=/etc      \
                --disable-efiemu       \
                --disable-werror

    make
    make install
    mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="grub-2.04.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build

cd $SRC
rm -v -rf $TG

exit $ERROR
