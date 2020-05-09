#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
    mkdir -v build
    cd       build
    ../configure                             \
          --prefix=/tools                    \
          --host=$LFS_TGT                    \
          --build=$(../scripts/config.guess) \
          --enable-kernel=3.2                \
          --with-headers=/tools/include

    make
    make install

	if [ "$1" == "--test" ]; then
	    #sanitiy check: check if compiling and linking works as expected
	    mkdir sanity_test
	    cd sanitiy_test
	    echo "#include <stdio.h>" > dummy.c
	    echo 'int main(){ return 1;}' >> dummy.c
	    $LFS_TGT-gcc dummy.c
	    readelf -l a.out | grep ': /tools'
	    local ERR=$?
	    [ $ERR -ne 0 ] && echo "[ERROR]: tool chain does not work properly"
	fi
	return $ERR
}

function _build_ext ()
{
	local ERR=0
    patch -Np1 -i ../glibc-2.31-fhs-1.patch
    case $(uname -m) in
        i?86)   ln -svf ld-linux.so.2 /lib/ld-lsb.so.3
        ;;
        x86_64) ln -svf ../lib/ld-linux-x86-64.so.2 /lib64
                ln -svf ../lib/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
        ;;
    esac

    mkdir -v build
    cd       build
    CC="gcc -ffile-prefix-map=/tools=/usr" \
    ../configure --prefix=/usr                          \
                 --disable-werror                       \
                 --enable-kernel=3.2                    \
                 --enable-stack-protector=strong        \
                 --with-headers=/usr/include            \
                 libc_cv_slibdir=/lib

    make
    case $(uname -m) in
      i?86)   ln -sfnv $(pwd)/elf/ld-linux.so.2        /lib ;;
      x86_64) ln -sfnv $(pwd)/elf/ld-linux-x86-64.so.2 /lib ;;
    esac
    make check
	ERR=$?
	[ $ERR -ne 0 ] && echo "[ERROR]: test failed"
    sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
    make install

    cp -v ../nscd/nscd.conf /etc/nscd.conf
    mkdir -pv /var/cache/nscd

	return $ERR
}

function _install_locale ()
{
    mkdir -pv /usr/lib/locale
    #make localedata/install-locales

	localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
	localedef -i de_DE -f ISO-8859-1 de_DE
	localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
	localedef -i de_DE -f UTF-8 de_DE.UTF-8
	localedef -i en_GB -f UTF-8 en_GB.UTF-8
	localedef -i en_HK -f ISO-8859-1 en_HK
	localedef -i en_PH -f ISO-8859-1 en_PH
	localedef -i en_US -f ISO-8859-1 en_US
	localedef -i en_US -f UTF-8 en_US.UTF-8
	localedef -i fr_FR -f ISO-8859-1 fr_FR
	localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
	localedef -i fr_FR -f UTF-8 fr_FR.UTF-8	
}

function _install_timezonedata ()
{
    tar -xzf ../../tzdata2019c.tar.gz

    ZONEINFO=/usr/share/zoneinfo
    mkdir -pv $ZONEINFO/{posix,right}
    
    for tz in etcetera southamerica northamerica europe africa antarctica  \
              asia australasia backward pacificnew systemv; do
        zic -L /dev/null   -d $ZONEINFO       ${tz}
        zic -L /dev/null   -d $ZONEINFO/posix ${tz}
        zic -L leapseconds -d $ZONEINFO/right ${tz}
    done

    cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
    #zic -d $ZONEINFO -p America/New_York
    zic -d $ZONEINFO -p Europe/Berlin
    ln -svf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
    unset ZONEINFO
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="glibc-2.31.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

case "$1" in
	--ext)
	_build_ext
	ERROR=$?  #failures and warnings to be ignored
	_install_locale
	_install_timezonedata
	;;
	*)
	_build
	ERROR=$?
	;;
esac


cd $SRC
rm -v -rf $TG

exit $ERROR
