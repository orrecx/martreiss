#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _help ()
{
	echo "Automation of a build of a kernel required a preconfigured kernel config"
	echo "you can generate one by using the config menu interface by calling 'make menuconfig'"
}

function _headers () 
{
    make mrproper
   	make headers
	if [ "$1" == "optimized" ]; then
	    find usr/include -name '.*' -delete
	    rm usr/include/Makefile
	fi
   	cp -rv usr/include/* /tools/include
}

function _build ()
{
	local ERR=0
    make mrproper
	#make menuconfig
    #ERR=$?
    cp -v $1 .config
    
    if [ $ERR -eq 0 ]; then
        make

        make modules_install

        #copy build artifacts to /boot 
        cp -iv arch/x86/boot/bzImage /boot/vmlinuz-5.5.3-lfs-9.1
        cp -iv System.map /boot/System.map-5.5.3
        cp -iv .config /boot/config-5.5.3

        install -d /usr/share/doc/linux-5.5.3
        cp -r Documentation/* /usr/share/doc/linux-5.5.3
    else
        echo "[ERROR]: make menuconfig failed"
    fi
	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="linux-5.5.3.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

case "$1" in
	--headers)
	_headers
	;;
	--headers_optimized)
	_headers "optimized"
	;;
	--kernel)
	shift
	if [ "$1" == "--config" ]; then
		shift
		CONF="$1"
		[ -n $CONF ] && [ ! -e "$CONF" ] && _build $CONF || _help && ERROR=1
	else
		_help
		ERROR=2
	fi
	;;
	*)
	echo "[ERROR]: unknown argument"
	ERROR=1
	;;
esac

cd $SRC
rm -v -rf $TG

exit $ERROR
