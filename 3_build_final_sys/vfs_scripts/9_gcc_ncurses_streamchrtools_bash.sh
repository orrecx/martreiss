SRC="/sources"

#------------------------------------------------

function install_gcc ()
{
    cd $SRC
    local TG=$(extract gcc-9.2.0.tar.xz )
    cd $TG

    case $(uname -m) in
      x86_64)
        sed -e '/m64=/s/lib64/lib/' \
            -i.orig gcc/config/i386/t-linux64
      ;;
    esac
    sed -e '1161 s|^|//|' \
        -i libsanitizer/sanitizer_common/sanitizer_platform_limits_posix.cc
    mkdir -v build
    cd       build
    SED=sed                               \
    ../configure --prefix=/usr            \
                 --enable-languages=c,c++ \
                 --disable-multilib       \
                 --disable-bootstrap      \
                 --with-system-zlib
    make
    ulimit -s 32768
    chown -Rv nobody . 
    su nobody -s /bin/bash -c "PATH=$PATH make -k check"
    ../contrib/test_summary
    make install
    rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/9.2.0/include-fixed/bits/
    chown -v -R root:root /usr/lib/gcc/*linux-gnu/9.2.0/include{,-fixed}
    ln -sv ../usr/bin/cpp /lib
    ln -sv gcc /usr/bin/cc
    install -v -dm755 /usr/lib/bfd-plugins
    ln -svf ../../libexec/gcc/$(gcc -dumpmachine)/9.2.0/liblto_plugin.so \
            /usr/lib/bfd-plugins/
    
    echo 'int main(){}' > dummy.c
    cc dummy.c -v -Wl,--verbose &> dummy.log
    readelf -l a.out | grep ': /lib'
    local ERR=$?
    if [ $ERR -eq 0 ]; then
        grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
        #expected result:
        #/usr/lib/gcc/x86_64-pc-linux-gnu/9.2.0/../../../../lib/crt1.o succeeded
        #/usr/lib/gcc/x86_64-pc-linux-gnu/9.2.0/../../../../lib/crti.o succeeded
        #/usr/lib/gcc/x86_64-pc-linux-gnu/9.2.0/../../../../lib/crtn.o succeeded
        grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
        #expected result:
        #SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib64")
        #SEARCH_DIR("/usr/local/lib64")
        #SEARCH_DIR("/lib64")
        #SEARCH_DIR("/usr/lib64")
        #SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib")
        #SEARCH_DIR("/usr/local/lib")
        #SEARCH_DIR("/lib")
        #SEARCH_DIR("/usr/lib");                    
    else
        echo "[ERROR]: fail to build gcc."
    fi

    mkdir -pv /usr/share/gdb/auto-load/usr/lib
    mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

    rm -rf $TG
    cd $SRC
    return $ERR
}

function install_pkg-config ()
{
    cd $SRC
    local TG=$(extract pkg-config-0.29.2.tar.gz )
    cd $TG

    ./configure --prefix=/usr              \
                --with-internal-glib       \
                --disable-host-tool        \
                --docdir=/usr/share/doc/pkg-config-0.29.2
    make
    make check
    local ERR=$?
    make install

    rm -rf $TG
    cd $SRC
    return $ERR
}


function install_ncurses ()
{
    cd $SRC
    local TG=$(extract ncurses-6.2.tar.xz )
    cd $TG

    sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
    ./configure --prefix=/usr           \
                --mandir=/usr/share/man \
                --with-shared           \
                --without-debug         \
                --without-normal        \
                --enable-pc-files       \
                --enable-widec
    make
    make install
    mv -v /usr/lib/libncursesw.so.6* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so
    for lib in ncurses form panel menu ; do
        rm -vf                    /usr/lib/lib${lib}.so
        echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
        ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
    done
    rm -vf                     /usr/lib/libcursesw.so
    echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
    ln -sfv libncurses.so      /usr/lib/libcurses.so
    mkdir -v       /usr/share/doc/ncurses-6.2
    cp -v -R doc/* /usr/share/doc/ncurses-6.2
    make distclean
    ./configure --prefix=/usr    \
                --with-shared    \
                --without-normal \
                --without-debug  \
                --without-cxx-binding \
                --with-abi-version=5 
    make sources libs
    cp -av lib/lib*.so.5* /usr/lib

    rm -rf $TG
    cd $SRC
}

function install_libcap ()
{
    cd $SRC
    local TG=$(extract libcap-2.31.tar.xz )
    cd $TG

    sed -i '/install.*STA...LIBNAME/d' libcap/Makefile
    make lib=lib
    make test
    local ERR=$?
    make lib=lib install
    chmod -v 755 /lib/libcap.so.2.31

    rm -rf $TG
    cd $SRC
    return $ERR
}


function install_sed ()
{
    cd $SRC
    local TG=$(extract sed-4.8.tar.xz )
    cd $TG

    sed -i 's/usr/tools/'                 build-aux/help2man
    sed -i 's/testsuite.panic-tests.sh//' Makefile.in
    ./configure --prefix=/usr --bindir=/bin
    make
    make html
    make check
    local ERR=$?
    make install
    install -d -m755           /usr/share/doc/sed-4.8
    install -m644 doc/sed.html /usr/share/doc/sed-4.8

    rm -rf $TG
    cd $SRC
    return $ERR
}

function install_psmisc ()
{
    cd $SRC
    local TG=$(extract psmisc-23.2.tar.xz )
    cd $TG

    ./configure --prefix=/usr
    make
    make install
    mv -v /usr/bin/fuser   /bin
    mv -v /usr/bin/killall /bin

    rm -rf $TG
    cd $SRC
}


function install_iana-etc ()
{
    cd $SRC
    local TG=$(extract iana-etc-2.30.tar.bz2 )
    cd $TG

    make
    make install

    rm -rf $TG
    cd $SRC
}


function install_bison ()
{
    cd $SRC
    local TG=$(extract bison-3.5.2.tar.xz )
    cd $TG

    ./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.5.2
    make
    make install

    rm -rf $TG
    cd $SRC
}

function install_flex ()
{
    cd $SRC
    local TG=$(extract flex-2.6.4.tar.gz )
    cd $TG

    sed -i "/math.h/a #include <malloc.h>" src/flexdef.h
    HELP2MAN=/tools/bin/true ./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.4
    make
    make check
    local ERR=$?
    make install

    rm -rf $TG
    cd $SRC
    return $ERR
}

function install_grep ()
{
    cd $SRC
    local TG=$(extract grep-3.4.tar.xz )
    cd $TG

    ./configure --prefix=/usr --bindir=/bin    
    make
    make check
    local ERR=$?
    make install

    rm -rf $TG
    cd $SRC
    return $ERR
}

function install_bash ()
{
    cd $SRC
    local TG=$(extract bash-5.0.tar.gz )
    cd $TG

    patch -Np1 -i ../bash-5.0-upstream_fixes-1.patch
    ./configure --prefix=/usr                    \
                --docdir=/usr/share/doc/bash-5.0 \
                --without-bash-malloc            \
                --with-installed-readline
    make
    #chown -Rv nobody .
    #su nobody -s /bin/bash -c "PATH=$PATH HOME=/home make tests"
    make install
    mv -vf /usr/bin/bash /bin

    rm -rf $TG
    cd $SRC
    return $ERR
}

#------------------------------------------------

source /vfs_scripts/utils.sh
#--------------- main ---------------------------
s_start $0
ST=$?

run_cmd install_gcc
run_cmd install_pkg-config
run_cmd install_ncurses
run_cmd install_libcap
run_cmd install_sed
run_cmd install_psmisc
run_cmd install_iana-etc
run_cmd install_bison
run_cmd install_flex
run_cmd install_grep
run_cmd install_bash

s_end $0
ED=$?
s_duration $0 $ST $ED
exit $ERROR