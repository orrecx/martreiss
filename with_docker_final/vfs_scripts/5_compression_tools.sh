SRC="$LFS/sources"

#------------------------------------------------

function install_zlib()
{
    cd $SRC
    tar xJf zlib-1.2.11.tar.xz
    cd zlib-1.2.11

    ./configure --prefix=/usr
    make
    make check
    make install
    mv -v /usr/lib/libz.so.* /lib
    ln -svf ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so

    cd $SRC
    rm -rf zlib-1.2.11
}

function build_bzip2 ()
{
    cd $SRC
    local TG="bzip2-1.0.8"
    tar xvzf "$TG.tar.gz"
    cd $TG

    patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
    sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
    sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
    make -f Makefile-libbz2_so
    make clean
    make
    make PREFIX=/usr install

    cp -v bzip2-shared /bin/bzip2
    cp -av libbz2.so* /lib
    ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
    rm -v /usr/bin/{bunzip2,bzcat,bzip2}
    ln -sv bzip2 /bin/bunzip2
    ln -sv bzip2 /bin/bzcat

    cd $SRC
    rm -rf $TG
}

function install_xz ()
{
    cd $SRC
    tar xvJf "xz-5.2.4.tar.xz"
    cd xz-5.2.4

    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/xz-5.2.4
    make
    make install
    mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
    mv -v /usr/lib/liblzma.so.* /lib
    ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so

    cd $SRC
    rm -rf xz-5.2.4
}

#------------------------------------------------

source $BUILD_SCRIPTS_DIR/utils.sh
#--------------- main ---------------------------
s_start $0
ST=$?

run_cmd install_zlib
run_cmd install_bzip2
run_cmd install_xz

s_end $0
ED=$?
s_duration $0 $ST $ED
