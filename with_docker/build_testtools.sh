#!/bin/bash
LFS_USER_ID=1001
SRC="$LFS/sources"

function build_tlc-8_6_10 ()
{
    cd $SRC
    local TG="tcl8.6.10"
    tar xzvf "$TG-src.tar.gz"
    cd $TG
    cd unix
    ./configure --prefix=/tools
    make
    make install
    chmod -v u+w /tools/lib/libtcl8.6.so
    make install-private-headers
    ln -sv tclsh8.6 /tools/bin/tclsh

    #TZ=UTC make test

    cd $SRC
    rm -rf $TG
}

function build_expect-5_45_4 ()
{
    cd $SRC
    local TG="expect5.45.4"
    tar xvzf "$TG.tar.gz"
    cd $TG
    cp -v configure{,.orig}
    sed 's:/usr/local/bin:/bin:' configure.orig > configure
    ./configure --prefix=/tools       \
                --with-tcl=/tools/lib \
                --with-tclinclude=/tools/include
    make
    make test
    make SCRIPTS="" install

    cd $SRC
    rm -rf $TG
}

function build_dejagnu ()
{
    cd $SRC
    local TG="dejagnu-1.6.2"
    tar xvzf "$TG.tar.gz"
    cd $TG
    ./configure --prefix=/tools
    make install
    make check
    
    cd $SRC
    rm -rf $TG
}
