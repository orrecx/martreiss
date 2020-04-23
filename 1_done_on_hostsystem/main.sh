#!/bin/bash

function _help ()
{
    echo "USAGE: $(basename $0) -i|--install|-c|--clear|--disk <disk>" 
}

[ $(id --user) -ne 0 ] && echo "[ERROR]: only root is allowed to run this script. use sudo" && exit 1
INSTALL=
CLEAR=
DISK=

[ -z "$1" ] && echo "[ERROR]:" && _help && exit 1
while [ "$1" ]; do
    case "$1" in
    -i|--install) INSTALL="1" ;;
    -c|--clear)   CLEAR="1"   ;;
    --disk)
        shift
        DISK="$1"
        ;;
    *)   echo -e "[ERROR]:" && _help ;;
    esac
    shift
done

export LFS="/mnt/lfs"
if [ -n "$CLEAR" ]; then
    echo "================ MAIN: CLEAR ================"
    chown -v -R root:root $LFS
    echo "userdel lfs"
    userdel lfs
    for D in $(ls -1 $LFS | grep -v lost ); do rm -rvf $D; done
    rm -vf /tools
    cd /bin
    ln -v -s -f /usr/bin/dash sh
    cd -
    umount -v $LFS
    [ -e "/etc/fstab.backup" ] && mv -v /etc/fstab.backup /etc/fstab
    [ -e "/root/.bashrc.backup" ] && mv -v /root/.bashrc.backup  /root/.bashrc
    ( echo "p"; echo "d"; echo ""; echo "w" ) | fdisk $DISK
    echo "wait..."
    sleep 2
fi

if [ -n "$INSTALL" ]; then
    echo "================ MAIN: INSTALL ================"
    if [ -b "$DISK" ]; then
        CD=$(realpath $0)
        CD=$(dirname $CD)
        cd $CD

        ./1_versioncheck.sh
        ./2_prepare_tools.sh
        ./3_prepare_lfs_filesystem.sh "$DISK"
        ./4_prepare_build_environment.sh
        ./5_prepare_lfs_user.sh
    else
        echo "[ERROR]: specified --disk '$DISK' is not a block-special file"
        exit 4
    fi
fi

