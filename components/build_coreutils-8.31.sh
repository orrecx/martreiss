#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
    FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=$TOOLS_SLINK --enable-install-program=hostname
    make
	if [ "$1" == "--test" ]; then
	    make RUN_EXPENSIVE_TESTS=yes check
		#ERR=$? #ignore test result for now
	fi
	[ $ERR -eq 0 ] && make install || echo "[ERROR]: build failed"
	return $ERR
}

function _build_ext ()
{
	local ERR=0
    patch -Np1 -i ../coreutils-8.31-i18n-1.patch
    sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk
    autoreconf -fiv
    FORCE_UNSAFE_CONFIGURE=1 ./configure \
                --prefix=/usr            \
                --enable-no-install-program=kill,uptime
    make
	if [ "$1" == "--test" ]; then
    	make NON_ROOT_USERNAME=nobody check-root
    	ERR=$?
    	if [ $ERR -eq 0 ]; then
    		echo "dummy:x:1000:nobody" >> /etc/group
    		chown -Rv nobody . 
    		su nobody -s /bin/bash \
    	          -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
    		ERR=$?
    		sed -i '/dummy/d' /etc/group
    	fi			
		[ $ERR -ne 0 ] && echo "[ERROR]: test failed"
	fi
    make install 
    mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
    mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
    mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
    mv -v /usr/bin/chroot /usr/sbin
    mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
    sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8
    mv -v /usr/bin/{head,nice,sleep,touch} /bin
	return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="coreutils-8.31.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

case "$1" in
	--ext)
	_build_ext --test
	;;
	*)
	_build --test
	ERROR=$?
	;;
esac

cd $SRC
rm -v -rf $TG

exit $ERROR
