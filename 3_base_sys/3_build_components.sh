#!/bin/bash
cd "$( dirname $(realpath $0))"

function adjust_build_toolchain ()
{
    local ERR=0
    mv -v /tools/bin/{ld,ld-old}
    mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
    cp -v /tools/bin/{ld-new,ld}
    ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld

    #change gcc spec
    gcc -dumpspecs | sed -e 's@/tools@@g'                   \
        -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
        -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
        `dirname $(gcc --print-libgcc-file-name)`/specs

    #test if it works
    echo 'int main(){}' > dummy.c
    echo "compile dummy.c"
    cc dummy.c -v -Wl,--verbose &> dummy.log
    [ $? -ne 0 ] && echo "[ERROR]: failed to compile dummy.c" && cat dummy.log
    readelf -l a.out | grep ': /lib'
    ERR=$?

    if [ $ERR -ne 0 ]; then
        echo "[ERROR]: configuration of toolchain failed"
    else
        set -v
        grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
        grep -B1 '^ /usr/include' dummy.log
        grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
        grep "/lib.*/libc.so.6 " dummy.log
        grep found dummy.log
        set +v
    fi
    rm -v dummy.c a.out dummy.log

    return $ERR    
}

#------------------------------------------------

source ../common/config.sh
source ../common/utils.sh
#------------------------------------------------
BUILD_SCRIPT_DIR="../$COMPONENTS_DIR"

s_start $0
START_TIME=$?

$BUILD_SCRIPT_DIR/build_linux-5.5.3.sh      --headers_optimized
$BUILD_SCRIPT_DIR/build_man-pages-5.05.sh

$BUILD_SCRIPT_DIR/build_glibc-2.31.sh       --ext
adjust_build_toolchain
[ $? -ne 0 ] && exit 1

$BUILD_SCRIPT_DIR/build_zlib-1.2.11.sh
$BUILD_SCRIPT_DIR/build_bzip2-1.0.8.sh      --ext
$BUILD_SCRIPT_DIR/build_xz-5.2.4.sh         --ext
$BUILD_SCRIPT_DIR/build_file-5.38.sh
$BUILD_SCRIPT_DIR/build_readline-8.0.sh
$BUILD_SCRIPT_DIR/build_m4-1.4.18.sh
$BUILD_SCRIPT_DIR/build_binutils-2.34.sh    --ext
$BUILD_SCRIPT_DIR/build_gmp-6.2.0.sh
$BUILD_SCRIPT_DIR/build_mpfr-4.0.2.sh
$BUILD_SCRIPT_DIR/build_mpc-1.1.0.sh
$BUILD_SCRIPT_DIR/build_attr-2.4.48.sh
$BUILD_SCRIPT_DIR/build_acl-2.2.53.sh
$BUILD_SCRIPT_DIR/build_shadow-4.8.1.sh

$BUILD_SCRIPT_DIR/build_gcc-9.2.0.sh        --ext
[ $? -ne 0 ] && exit 1

$BUILD_SCRIPT_DIR/build_pkg-config-0.29.2.sh
$BUILD_SCRIPT_DIR/build_ncurses-6.2.sh      --ext
$BUILD_SCRIPT_DIR/build_libcap-2.31.sh
$BUILD_SCRIPT_DIR/build_sed-4.8.sh          --ext
$BUILD_SCRIPT_DIR/build_psmisc-23.2.sh
$BUILD_SCRIPT_DIR/build_iana-etc-2.30.sh
$BUILD_SCRIPT_DIR/build_bison-3.5.2.sh      --ext
$BUILD_SCRIPT_DIR/build_flex-2.6.4.sh       --ext
$BUILD_SCRIPT_DIR/build_grep-3.4.sh         --ext
$BUILD_SCRIPT_DIR/build_bash-5.0.sh         --ext

$BUILD_SCRIPT_DIR/build_libtool-2.4.6.sh
$BUILD_SCRIPT_DIR/build_gdbm-1.18.1.sh
$BUILD_SCRIPT_DIR/build_gperf-3.1.sh
$BUILD_SCRIPT_DIR/build_expat-2.2.9.sh
$BUILD_SCRIPT_DIR/build_inetutils-1.9.4.sh
$BUILD_SCRIPT_DIR/build_perl-5.30.1.sh      --ext
$BUILD_SCRIPT_DIR/build_XML-Parser-2.46.sh
$BUILD_SCRIPT_DIR/build_intltool-0.51.0.sh
$BUILD_SCRIPT_DIR/build_autoconf-2.69.sh
$BUILD_SCRIPT_DIR/build_automake-1.16.1.sh
$BUILD_SCRIPT_DIR/build_kmod-26.sh
$BUILD_SCRIPT_DIR/build_gettext-0.20.1.sh   --ext
$BUILD_SCRIPT_DIR/build_elfutils-0.178.sh
$BUILD_SCRIPT_DIR/build_libffi-3.3.sh
$BUILD_SCRIPT_DIR/build_openssl-1.1.1d.sh
$BUILD_SCRIPT_DIR/build_Python-3.8.1.sh     --ext
$BUILD_SCRIPT_DIR/build_ninja-1.10.0.sh
$BUILD_SCRIPT_DIR/build_meson-0.53.1.sh
$BUILD_SCRIPT_DIR/build_coreutils-8.31.sh   --ext
$BUILD_SCRIPT_DIR/build_check-0.14.0.sh
$BUILD_SCRIPT_DIR/build_diffutils-3.7.sh    --ext
$BUILD_SCRIPT_DIR/build_gawk-5.0.1.sh       --ext
$BUILD_SCRIPT_DIR/build_findutils-4.7.0.sh  --ext
$BUILD_SCRIPT_DIR/build_groff-1.22.4.sh
$BUILD_SCRIPT_DIR/build_grub-2.04.sh
$BUILD_SCRIPT_DIR/build_less-551.sh
$BUILD_SCRIPT_DIR/build_gzip-1.10.sh        --ext
$BUILD_SCRIPT_DIR/build_zstd-1.4.4.sh
$BUILD_SCRIPT_DIR/build_iproute2-5.5.0.sh
$BUILD_SCRIPT_DIR/build_kbd-2.2.0.sh
$BUILD_SCRIPT_DIR/build_libpipeline-1.5.2.sh
$BUILD_SCRIPT_DIR/build_make-4.3.tar.sh     --ext
$BUILD_SCRIPT_DIR/build_patch-2.7.6.sh      --ext
$BUILD_SCRIPT_DIR/build_man-db-2.9.0.sh
$BUILD_SCRIPT_DIR/build_tar-1.32.sh         --ext
$BUILD_SCRIPT_DIR/build_texinfo-6.7.sh      --ext
$BUILD_SCRIPT_DIR/build_vim-8.2.0190.sh
$BUILD_SCRIPT_DIR/build_procps-ng-3.3.15.sh
$BUILD_SCRIPT_DIR/build_util-linux-2.35.1.sh
$BUILD_SCRIPT_DIR/build_e2fsprogs-1.45.5.sh
$BUILD_SCRIPT_DIR/build_sysklogd-1.5.1.sh
$BUILD_SCRIPT_DIR/build_sysvinit-2.96.sh
$BUILD_SCRIPT_DIR/build_eudev-3.2.9.sh

#-------------------------------------

s_end $0
END_TIME=$?

s_duration $0 $START_TIME $END_TIME 

exit 0