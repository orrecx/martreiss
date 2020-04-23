#!/bin/bash
CLEAR=
BUILD=
BUILD_SCRIPTS_DIR="vfs_scripts"
SYS_CONF_SCRIPTS_DIR="vfs_config_scripts"


function _help ()
{
    echo "USAGE: $(basename $0) -c|--clear|-b|--build" 
}

function _clear ()
{
    umount -v $LFS/proc
    umount -v $LFS/run
    umount -v $LFS/sys
    umount -v $LFS/dev/pts
    umount -v $LFS/dev
    rm -v -f $LFS/dev/console
    rm -v -f $LFS/dev/null
    rm -v -rf $LFS/{dev,proc,sys,run}
    rm -v -rf $LFS/{boot,etc,home,lib,mnt,opt}
    rm -v -rf $LFS/{media,sbin,srv,var,usr,tmp,root,bin}
    case $(uname -m) in
        x86_64) rm -v -rf $LFS/lib64 ;;
    esac

    mv -v  $LFS/tools/bin/{ld-old, ld}
    mv -v  $LFS/tools/$(uname -m)-pc-linux-gnu/bin/{ld-old, ld}
    ln -v -s -f $LFS/tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld

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

function intermediate_configuration ()
{
    #make this possible in order the new compiled linux-kernel to /boot
    mount --bind /boot /mnt/lfs/boot
}

#------------------------ main ------------------------
[ "$(id -u)" -ne $(id -u root) ] && echo "[ERROR]: run this script as root" && exit 1
[ -z "$LFS" -o ! -d "$LFS" ] && \
echo "[ERROR]: Environment variable LFS is not set yet or directory $LFS does not exist yet" && exit 2

[ -z "$1" ] && echo "[ERROR]:" && _help && exit 3
while [ "$1" ]; do
    case "$1" in
    -c|--clear) CLEAR="1" ;;
    -b|--build) BUILD="1" ;;
    *)   echo -e "[ERROR]:" && _help ;;
    esac
    shift
done

echo "================ MAIN: CONSTRUCT SYSTEM ================"

if [ -n "$CLEAR" ] ; then
    _clear
fi

if [ -n "$BUILD" ] ; then
    CD=$(realpath $0)
    CD=$(dirname $CD)
    cd $CD

    #./1_create_virtual_fs.sh
    cp -f -v -r $BUILD_SCRIPTS_DIR $LFS/$BUILD_SCRIPTS_DIR
    cp -f -v utils.sh $LFS/$BUILD_SCRIPTS_DIR

    #run_in_lfs_env "/$BUILD_SCRIPTS_DIR/vfs_main.sh" ":/tools/bin:/tools/$(uname -m)-pc-linux-gnu/bin" 
    #run_in_lfs_env "/$BUILD_SCRIPTS_DIR/12_cleanup.sh"

    #intermediate_configuration

    #rm -v -rf $LFS/$BUILD_SCRIPTS_DIR

    cp -f -v -r $SYS_CONF_SCRIPTS_DIR $LFS/$SYS_CONF_SCRIPTS_DIR
    cp -f -v utils.sh $LFS/$SYS_CONF_SCRIPTS_DIR
    #run_in_lfs_env "/$SYS_CONF_SCRIPTS_DIR/sys_config_main.sh"

    #rm -v -rf $LFS/$SYS_CONF_SCRIPTS_DIR
fi
