#!/bin/bash
LFS_USER_ID=1001
SRC="$LFS/sources"


function build_generic
{
    local T=$1
    local LN=$(echo ${#T})
    local N=$(expr $LN - 7)
    local TG="$(echo ${T:0:$N})"
    local EXT="$(echo ${T:$(expr $N + 5) })"
    local TAR_OP=$( [ $EXT = "xz" ] && echo "xvJf" || echo "xvzf" )
    
    tar $TAR_OP "$TG.tar.$EXT"
    cd $TG
    ./configure --prefix=/tools "$2"
    make
    make check
    make install

    cd $SRC
    rm -rf $TG
}

function build_bison ()
{
    build_generic "bison-3.5.2.tar.xz"
}

function build_diffutils ()
{
    build_generic "diffutils-3.7.tar.xz"
}

function build_file ()
{
    build_generic "file-5.38.tar.gz"
}

function build_findutils ()
{
    build_generic "findutils-4.7.0.tar.xz"
}

function build_gawk ()
{
    build_generic "gawk-5.0.1.tar.xz"
}

function build_grep ()
{
    build_generic "grep-3.4.tar.xz"
}


function build_gzip ()
{
    build_generic "gzip-1.10.tar.xz"
}

function build_make ()
{
    build_generic "make-4.3.tar.gz" "--without-guile"
}

function build_patch ()
{
    build_generic "patch-2.7.6.tar.xz"
}

function build_sed ()
{
    build_generic "sed-4.8.tar.xz"
}

function build_tar ()
{
    build_generic "tar-1.32.tar.xz"
}

function build_textinfo ()
{
    build_generic "texinfo-6.7.tar.xz"
}

function build_xz ()
{
    build_generic "xz-5.2.4.tar.xz"
}
