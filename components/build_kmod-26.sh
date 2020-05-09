#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    ./configure --prefix=/usr          \
                --bindir=/bin          \
                --sysconfdir=/etc      \
                --with-rootlibdir=/lib \
                --with-xz              \
                --with-zlib
    make
    make install

    for target in depmod insmod lsmod modinfo modprobe rmmod; do
      ln -svf ../bin/kmod /sbin/$target
    done

    ln -svf kmod /bin/lsmod			
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="kmod-26.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build

cd $SRC
rm -v -rf $TG

exit $ERROR
