#!/bin/bash
cd "$( dirname $(realpath $0))"

BUILD_SCRIPTS_DIR="vfs_scripts"
SYS_CONF_SCRIPTS_DIR="vfs_config_scripts"
DOCKER_CONTEXT=0
BUILD=0
CLEAR=0

function _help ()
{
    echo "USAGE: $(basename $0) -c|--clear|-b|--build" 
}

function run_in_lfs_env ()
{
    chroot "$LFS" /tools/bin/env -i \
        HOME=/root                  \
        TERM="$TERM"                \
        PS1='(lfs chroot) \u:\w\$ ' \
        PATH=/bin:/usr/bin:/sbin:/usr/sbin"$2" \
        /tools/bin/bash -c "$1"
}

function bind_bootdir_from_host_to_lfs_env ()
{
    #make this possible in order for the new compiled linux-kernel to /boot
    mount --bind /boot /mnt/lfs/boot
}

source ../common/config.sh
source ../common/utils.sh
#------------------------ main ------------------------
s_start $0
START_TIME=$?

[ -z "$1" ] && echo "[ERROR]:" && _help && exit 3
while [ "$1" ]; do
    case "$1" in
    -c|--clear) CLEAR=1 ;;
    -b|--build) BUILD=1 ;;
    --docker)
        export LFS=""
        DOCKER_CONTEXT=1 
        ;;
    *)   echo -e "[ERROR]:" && _help ;;
    esac
    shift
done

if [ $DOCKER_CONTEXT -eq 0 ]; then
    [ "$(id -u)" -ne $(id -u root) ] && echo "[ERROR]: run this script as root" && exit 1
    [ -z "$LFS" -o ! -d "$LFS" ] && \
    echo "[ERROR]: Environment variable LFS is not set yet or directory $LFS does not exist yet" && exit 2
fi

echo "================ CONSTRUCT BASIC SYSTEM ================"
if [ $CLEAR -eq 1 ] ; then
    _clear
fi

if [ $BUILD -eq 1 ] ; then
    ./1_create_virtual_fs.sh
    cp -f -v -r $BUILD_SCRIPTS_DIR $LFS/$BUILD_SCRIPTS_DIR
    cp -f -v ../common/utils.sh $LFS/$BUILD_SCRIPTS_DIR
    run_in_lfs_env "/$BUILD_SCRIPTS_DIR/vfs_main.sh" ":/tools/bin:/tools/$(uname -m)-pc-linux-gnu/bin" 
    #run_in_lfs_env "/$BUILD_SCRIPTS_DIR/12_cleanup.sh"
    rm -v -rf $LFS/$BUILD_SCRIPTS_DIR
    #bind_bootdir_from_host_to_lfs_env
    cp -f -v -r $SYS_CONF_SCRIPTS_DIR $LFS/$SYS_CONF_SCRIPTS_DIR
    cp -f -v ../common/utils.sh $LFS/$SYS_CONF_SCRIPTS_DIR
    cp -f -v kernel_build_config $LFS/$SYS_CONF_SCRIPTS_DIR
    cp -f -v bashrc $LFS/root/.bashrc
    cp -f -v profile $LFS/root/.profile
    run_in_lfs_env "/$SYS_CONF_SCRIPTS_DIR/sys_config_main.sh"
    rm -v -rf $LFS/$SYS_CONF_SCRIPTS_DIR
fi

if [ $DOCKER_CONTEXT -eq 1 ] ; then
    ./1_create_virtual_fs.sh
    ./build_components.sh      
    cp -f -v bashrc /root/.bashrc
    cp -f -v profile /root/.profile
    ./$SYS_CONF_SCRIPTS_DIR/sys_config_main.sh
fi

s_end $0
END_TIME=$?
s_duration $0 $START_TIME $END_TIME 

exit 0