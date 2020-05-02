#no need for shebang because /bin/bash does not exist and this script is being run by bash

BUILD_SCRIPTS_DIR="$WRK/vfs_scripts"

source $BUILD_SCRIPTS_DIR/utils.sh

echo "================ VFS MAIN ================"
s_start $0
S=$?

$BUILD_SCRIPTS_DIR/2_vfs_populate.sh
hash -r #clear bash cache
$BUILD_SCRIPTS_DIR/3_linux_headers_man_pages_and_glibc.sh
$BUILD_SCRIPTS_DIR/4_configure_toolchain.sh
ERROR=$?
if [ $ERROR -ne 0 ]; then
    echo "[ERROR]: toolchains are mess up"
else
    $BUILD_SCRIPTS_DIR/5_compression_tools.sh
    $BUILD_SCRIPTS_DIR/6_file_readline_m4_bc_binutils.sh
    $BUILD_SCRIPTS_DIR/7_math_tools.sh
    $BUILD_SCRIPTS_DIR/8_access_right_and_file_attr.sh
    $BUILD_SCRIPTS_DIR/9_gcc_ncurses_streamchrtools_bash.sh #also build bash
    #from this point on use the new built bash
    bash -c $BUILD_SCRIPTS_DIR/after_build_of_new_bash.sh
fi

rm -rvf /tmp/*

s_end $0
E=$?
s_duration $0 $S $E

exit $ERROR
