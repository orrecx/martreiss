#!/bin/bash
cd "$( dirname $(realpath $0))"

#------------------------------------------------

source ../common/config.sh
source ../common/utils.sh
#------------------------------------------------
BUILD_SCRIPT_DIR="../$COMPONENTS_DIR"

s_start $0
START_TIME=$?

$BUILD_SCRIPT_DIR/build_binutils-2.34.sh
$BUILD_SCRIPT_DIR/build_gcc-9.2.0.sh
$BUILD_SCRIPT_DIR/build_linux-5.5.3.sh --headers
$BUILD_SCRIPT_DIR/build_glibc-2.31.sh
$BUILD_SCRIPT_DIR/build_gcc-9.2.0.sh --libstdcxx

$BUILD_SCRIPT_DIR/build_binutils-2.34.sh --pass2
$BUILD_SCRIPT_DIR/build_gcc-9.2.0.sh --pass2
if [ $? -ne 0 ]; then
    echo "[ERROR]: failed to build gcc properly"
    exit 1
fi

$BUILD_SCRIPT_DIR/build_tcl8.6.10-src.sh
$BUILD_SCRIPT_DIR/build_expect5.45.4.sh
$BUILD_SCRIPT_DIR/build_dejagnu-1.6.2.sh
$BUILD_SCRIPT_DIR/build_m4-1.4.18.sh
$BUILD_SCRIPT_DIR/build_ncurses-6.2.sh
$BUILD_SCRIPT_DIR/build_bash-5.0.sh
$BUILD_SCRIPT_DIR/build_bison-3.5.2.sh
$BUILD_SCRIPT_DIR/build_bzip2-1.0.8.sh
$BUILD_SCRIPT_DIR/build_coreutils-8.31.sh
$BUILD_SCRIPT_DIR/build_diffutils-3.7.sh
$BUILD_SCRIPT_DIR/build_file-5.38.sh
$BUILD_SCRIPT_DIR/build_findutils-4.7.0.sh
$BUILD_SCRIPT_DIR/build_gawk-5.0.1.sh
$BUILD_SCRIPT_DIR/build_gettext-0.20.1.sh
$BUILD_SCRIPT_DIR/build_grep-3.4.sh
$BUILD_SCRIPT_DIR/build_gzip-1.10.sh
$BUILD_SCRIPT_DIR/build_make-4.3.sh
$BUILD_SCRIPT_DIR/build_patch-2.7.6.sh
$BUILD_SCRIPT_DIR/build_perl-5.30.1.sh
$BUILD_SCRIPT_DIR/build_Python-3.8.1.sh
$BUILD_SCRIPT_DIR/build_sed-4.8.sh
$BUILD_SCRIPT_DIR/build_tar-1.32.sh
$BUILD_SCRIPT_DIR/build_texinfo-6.7.sh
$BUILD_SCRIPT_DIR/build_xz-5.2.4.sh
#-------------------------------------

s_end $0
END_TIME=$?

s_duration $0 $START_TIME $END_TIME 
