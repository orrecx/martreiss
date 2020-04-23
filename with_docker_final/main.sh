CLEAR=
BUILD=
LFS="/lfs"
HOME="/lfs"
TERM="xterm-256color"
PATH=/bin:/usr/bin:/sbin:/usr/sbin:$LFS/tools/bin:$LFS/tools/x86_64-pc-linux-gnu/bin:$LFS/tools/x86_64-lfs-linux-gnu/bin

BUILD_SCRIPTS_DIR="$LFS/vfs_scripts"

export LFS HOME TERM PATH BUILD_SCRIPTS_DIR
#------------------------ main ------------------------
echo "================ MAIN: CONSTRUCT SYSTEM ================"

cd / 
$LFS/tools/bin/rm -rvf $( $LFS/tools/bin/ls -1 | $LFS/tools/bin/grep -v lfs )

$BUILD_SCRIPTS_DIR/vfs_main.sh 
