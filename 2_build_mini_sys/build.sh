#!/bin/bash
SRC="$LFS/sources"

#------------------------------------------------

function check_environment()
{
    [ -z "$LFS" ] && echo "[ERROR]: environment variable LFS not set" && exit 2
    [ -z "$LFS_TGT" ] && echo "[ERROR]: environment variable LFS_TGT not set" && exit 3    
}

function build_binutils()
{
    cd $SRC
    tar xJf binutils-2.34.tar.xz
    cd binutils-2.34
    mkdir -v build
    cd build
    ../configure --prefix=/tools            \
                 --with-sysroot=$LFS        \
                 --with-lib-path=/tools/lib \
                 --target=$LFS_TGT          \
                 --disable-nls              \
                 --disable-werror
    make
    make install
    cd $SRC
    rm -rf binutils-2.34
} 

function build_gcc()
{
    cd $SRC
    tar xJf gcc-9.2.0.tar.xz
    cd gcc-9.2.0
    tar -xf ../mpfr-4.0.2.tar.xz
    mv -v mpfr-4.0.2 mpfr
    tar -xf ../gmp-6.2.0.tar.xz
    mv -v gmp-6.2.0 gmp
    tar -xf ../mpc-1.1.0.tar.gz
    mv -v mpc-1.1.0 mpc

    for file in gcc/config/{linux,i386/linux{,64}}.h
    do
      cp -uv $file{,.orig}
      sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
          -e 's@/usr@/tools@g' $file.orig > $file
      echo '
    #undef STANDARD_STARTFILE_PREFIX_1
    #undef STANDARD_STARTFILE_PREFIX_2
    #define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
    #define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
      touch $file.orig
    done

    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

    mkdir -v build
    cd       build
    ../configure                                       \
        --target=$LFS_TGT                              \
        --prefix=/tools                                \
        --with-glibc-version=2.11                      \
        --with-sysroot=$LFS                            \
        --with-newlib                                  \
        --without-headers                              \
        --with-local-prefix=/tools                     \
        --with-native-system-header-dir=/tools/include \
        --disable-nls                                  \
        --disable-shared                               \
        --disable-multilib                             \
        --disable-decimal-float                        \
        --disable-threads                              \
        --disable-libatomic                            \
        --disable-libgomp                              \
        --disable-libquadmath                          \
        --disable-libssp                               \
        --disable-libvtv                               \
        --disable-libstdcxx                            \
        --enable-languages=c,c++

    make
    make install

    cd $SRC
    rm -rf gcc-9.2.0
}

function prepare_linux_header()
{
    cd $SRC
    tar xJf linux-5.5.3.tar.xz
    cd linux-5.5.3
    make mrproper
    make headers
    cp -rv usr/include/* /tools/include
    cd $SRC
    rm -rf linux-5.5.3
}

function build_c_library_Glibc()
{
    cd $SRC
    tar xJf glibc-2.31.tar.xz
    cd glibc-2.31
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

    #sanitiy check: check if compiling and linking works as expected
    mkdir sanity_test
    cd sanitiy_test
    echo "#include <stdio.h>" > dummy.c
    echo 'int main(){ return 1;}' >> dummy.c
    $LFS_TGT-gcc dummy.c
    readelf -l a.out | grep ': /tools'
    local ERR=$?
    [ $ERR -ne 0 ] && echo "[ERROR]: tool chain does not work properly"

    cd $SRC
    rm -rf glibc-2.31
    return $ERR
}

function build_Libstdcxx ()
{
    cd $SRC
    local TG="gcc-9.2.0"
    tar xJf $TG.tar.xz
    cd $TG
    mkdir -v build
    cd       build
    ../libstdc++-v3/configure           \
        --host=$LFS_TGT                 \
        --prefix=/tools                 \
        --disable-multilib              \
        --disable-nls                   \
        --disable-libstdcxx-threads     \
        --disable-libstdcxx-pch         \
        --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/9.2.0
    make
    make install
    cd $SRC
    rm -rf $TG
}

function build_binutils-2_34_pass2 ()
{
    cd $SRC
    local TG="binutils-2.34"
    tar xJf "$TG.tar.xz"
    cd $TG
    mkdir -v build
    cd       build

    CC=$LFS_TGT-gcc                \
    AR=$LFS_TGT-ar                 \
    RANLIB=$LFS_TGT-ranlib         \
    ../configure                   \
        --prefix=/tools            \
        --disable-nls              \
        --disable-werror           \
        --with-lib-path=/tools/lib \
        --with-sysroot

    make
    make install
    make -C ld clean
    make -C ld LIB_PATH=/usr/lib:/lib
    cp -v ld/ld-new /tools/bin

    cd $SRC
    rm -rf $TG
}

function build_gcc-9_2_0_pass2 ()
{
    cd $SRC
    local TG="gcc-9.2.0"
    tar xJf "$TG.tar.xz"
    cd $TG

    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
      `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

    for file in gcc/config/{linux,i386/linux{,64}}.h
    do
      cp -uv $file{,.orig}
      sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
          -e 's@/usr@/tools@g' $file.orig > $file
      echo '
    #undef STANDARD_STARTFILE_PREFIX_1
    #undef STANDARD_STARTFILE_PREFIX_2
    #define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
    #define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
      touch $file.orig
    done

    sed -e '/m64=/s/lib64/lib/' \
            -i.orig gcc/config/i386/t-linux64

    tar -xf ../mpfr-4.0.2.tar.xz
    mv -v mpfr-4.0.2 mpfr
    tar -xf ../gmp-6.2.0.tar.xz
    mv -v gmp-6.2.0 gmp
    tar -xf ../mpc-1.1.0.tar.gz
    mv -v mpc-1.1.0 mpc

    sed -e '1161 s|^|//|' \
        -i libsanitizer/sanitizer_common/sanitizer_platform_limits_posix.cc

    mkdir -v build
    cd       build

    CC=$LFS_TGT-gcc                                    \
    CXX=$LFS_TGT-g++                                   \
    AR=$LFS_TGT-ar                                     \
    RANLIB=$LFS_TGT-ranlib                             \
    ../configure                                       \
        --prefix=/tools                                \
        --with-local-prefix=/tools                     \
        --with-native-system-header-dir=/tools/include \
        --enable-languages=c,c++                       \
        --disable-libstdcxx-pch                        \
        --disable-multilib                             \
        --disable-bootstrap                            \
        --disable-libgomp

    make
    make install
    ln -sv gcc /tools/bin/cc

#sanity check
    echo 'int main(){}' > dummy.c
    cc dummy.c
    readelf -l a.out | grep ': /tools'
    local ERR=$?
    [ $ERR -ne 0 ] && echo "[ERROR]: tool chain does not work properly"

    cd $SRC
    rm -rf $TG
    return $ERR
}


function build_m4 ()
{
    cd $SRC
    local TG="m4-1.4.18"
    tar xvJf "$TG.tar.xz"
    cd $TG
    sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
    echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
    ./configure --prefix=/tools
    make
    make check
    make install

    cd $SRC
    rm -rf $TG
}

function build_ncurses ()
{
    cd $SRC
    local TG="ncurses-6.2"
    tar xvzf "$TG.tar.gz"
    cd $TG
    sed -i s/mawk// configure
    ./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite
    make
    make install
    ln -s libncursesw.so /tools/lib/libncurses.so    
    cd $SRC
    rm -rf $TG
}

function build_bash ()
{
    cd $SRC
    local TG="bash-5.0"
    tar xvzf "$TG.tar.gz"
    cd $TG
    ./configure --prefix=/tools --without-bash-malloc
    make
    make test
    make install
    ln -sv bash /tools/bin/sh

    cd $SRC
    rm -rf $TG
}


function build_bzip2 ()
{
    cd $SRC
    local TG="bzip2-1.0.8"
    tar xvzf "$TG.tar.gz"
    cd $TG
    make -f Makefile-libbz2_so
    make clean
    make
    make PREFIX=/tools install
    cp -v bzip2-shared /tools/bin/bzip2
    cp -av libbz2.so* /tools/lib
    ln -sv libbz2.so.1.0 /tools/lib/libbz2.so    
    cd $SRC
    rm -rf $TG
}

function build_coreutils ()
{
    cd $SRC
    local TG="coreutils-8.31"
    tar xvJf "$TG.tar.xz"
    cd $TG
    FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/tools --enable-install-program=hostname
    make
    make RUN_EXPENSIVE_TESTS=yes check
    make install

    cd $SRC
    rm -rf $TG
}

function build_gettext ()
{
    cd $SRC
    local TG="gettext-0.20.1"
    tar xvJf "$TG.tar.xz"
    cd $TG
    ./configure --disable-shared
    make
    cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /tools/bin

    cd $SRC
    rm -rf $TG
}


function build_perl ()
{
    cd $SRC
    local TG="perl-5.30.1"
    tar xvJf "$TG.tar.xz"
    cd $TG
    sh Configure -des -Dprefix=/tools -Dlibs=-lm -Uloclibpth -Ulocincpth
    make
    cp -v perl cpan/podlators/scripts/pod2man /tools/bin
    mkdir -pv /tools/lib/perl5/5.30.1
    cp -Rv lib/* /tools/lib/perl5/5.30.1
    cd $SRC
    rm -rf $TG
}

function build_python ()
{
    cd $SRC
    local TG="Python-3.8.1"
    tar xvJf "$TG.tar.xz"
    cd $TG
    sed -i '/def add_multiarch_paths/a \        return' setup.py
    ./configure --prefix=/tools --without-ensurepip
    make
    make install

    cd $SRC
    rm -rf $TG
}

function build_sample ()
{
    cd $SRC
    local TG=""
    tar xvJf "$TG.tar.xz"
    cd $TG


    cd $SRC
    rm -rf $TG
}

source ../common/utils.sh
source ./build_testtools.sh
source ./build_generics.sh
#------------------------------------------------

#--------------- main ---------------------------
cd $SRC
s_start $0
START_TIME=$?

check_environment
run_cmd build_binutils
run_cmd build_gcc
run_cmd prepare_linux_header
run_cmd build_c_library_Glibc
run_cmd build_Libstdcxx
run_cmd build_binutils-2_34_pass2
run_cmd build_gcc-9_2_0_pass2
if [ $? -ne 0 ]; then
    echo "[ERROR]: failed to build gcc properly"
    exit 1
fi
run_cmd build_tlc-8_6_10
run_cmd build_expect-5_45_4
run_cmd build_dejagnu
run_cmd build_m4
run_cmd build_ncurses
run_cmd build_bash
run_cmd build_bison
run_cmd build_bzip2
run_cmd build_coreutils
run_cmd build_diffutils
run_cmd build_file
run_cmd build_findutils
run_cmd build_gawk
run_cmd build_gettext
run_cmd build_grep
run_cmd build_gzip
run_cmd build_make
run_cmd build_patch
run_cmd build_perl
run_cmd build_python
run_cmd build_sed
run_cmd build_tar
run_cmd build_textinfo
run_cmd build_xz
#-------------------------------------
s_end $0
END_TIME=$?

s_duration $0 $END_TIME $START_TIME
