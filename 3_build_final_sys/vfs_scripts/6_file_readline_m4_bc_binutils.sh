SRC="/sources"

#------------------------------------------------
function install_file ()
{
    build_generic "file-5.38.tar.gz"
}

function install_readline ()
{
    cd $SRC
    local TG=$(extract readline-8.0.tar.gz )
    cd $TG
    
    sed -i '/MV.*old/d' Makefile.in
    sed -i '/{OLDSUFF}/c:' support/shlib-install
    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/readline-8.0
    make SHLIB_LIBS="-L/tools/lib -lncursesw"
    make SHLIB_LIBS="-L/tools/lib -lncursesw" install

    mv -v /usr/lib/lib{readline,history}.so.* /lib
    chmod -v u+w /lib/lib{readline,history}.so.*
    ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
    ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so
    install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.0

    rm -rf $TG
    cd $SRC
}

function install_m4 ()
{
    cd $SRC
    local TG=$(extract m4-1.4.18.tar.xz )
    cd $TG

    sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
    echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
    build_generic "$TG.tar.xz"
}

function install_bc ()
{
    cd $SRC
    local TG=$(extract bc-2.5.3.tar.gz )
    cd $TG
   
    PREFIX=/usr CC=gcc CFLAGS="-std=c99" ./configure.sh -G -O3
    make
    make test
    make install

    rm -rf $TG
    cd $SRC
}

function install_binutils ()
{
    cd $SRC
    local TG=$(extract binutils-2.34.tar.xz )
    cd $TG

    local T=`expect -c "spawn ls"`
    if [[ "$T" = *"spawn"* ]]; then
        sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in
        mkdir -v build
        cd       build
        ../configure --prefix=/usr       \
                     --enable-gold       \
                     --enable-ld=default \
                     --enable-plugins    \
                     --enable-shared     \
                     --disable-werror    \
                     --enable-64-bit-bfd \
                     --with-system-zlib
        make tooldir=/usr
        make -k check
        local ERR=$?
        make install             
    else
        echo "[ERROR]: expect -c spawn ls failed"
        ERR=1
    fi

    rm -rf $TG
    cd $SRC
    return $ERR
}

#------------------------------------------------

source $WRK/vfs_scripts/utils.sh
#--------------- main ---------------------------
s_start $0
ST=$?

run_cmd install_file
run_cmd install_readline
run_cmd install_m4
run_cmd install_bc
run_cmd install_binutils
ERROR=$?
if [ $ERROR -ne 0 ]; then
    echo "[ERROR]: install binutils failed"
fi

s_end $0
ED=$?
s_duration $0 $ST $ED
exit $ERROR