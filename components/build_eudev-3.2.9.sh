#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
    mkdir -pv /lib/udev/rules.d
    mkdir -pv /etc/udev/rules.d

    ./configure --prefix=/usr           \
                --bindir=/sbin          \
                --sbindir=/sbin         \
                --libdir=/usr/lib       \
                --sysconfdir=/etc       \
                --libexecdir=/lib       \
                --with-rootprefix=      \
                --with-rootlibdir=/lib  \
                --enable-manpages       \
                --disable-static
    make
 	if [ "$1" == "--test" ]; then
		make check
		ERR=$?
		[ $ERR -ne 0 ] && echo "[ERROR]: test failed"
	fi
	make install
    tar -xvf ../udev-lfs-20171102.tar.xz
    make -f udev-lfs-20171102/Makefile.lfs install
    udevadm hwdb --update
	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="eudev-3.2.9.tar.gz"

cd $SRC
TG=$( extract $COMP )
cd $TG

_build --test
ERROR=$?

cd $SRC
rm -v -rf $TG

exit $ERROR
