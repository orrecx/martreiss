#!/bin/bash

function _help ()
{
    echo "USAGE: $(basename $0) -i|--install|--docker|-c|--clear|--disk <disk>" 
}

[ $(id --user) -ne 0 ] && echo "[ERROR]: only root is allowed to run this script. use sudo" && exit 1
INSTALL=
CLEAR=
DISK=
DOCKER_CONTEXT=0

[ -z "$1" ] && echo "[ERROR]:" && _help && exit 1
while [ "$1" ]; do
    case "$1" in
    -i|--install) INSTALL="1" ;;
    -c|--clear)   CLEAR="1"   ;;
    --docker) DOCKER_CONTEXT=1 ;;
    --disk)
        shift
        DISK="$1"
        ;;
    *)   echo -e "[ERROR]:" && _help ;;
    esac
    shift
done

if [ $DOCKER_CONTEXT -eq 0 ]; then
    export LFS="/mnt/lfs"
    [ ! -b "$DISK" ] && echo "[ERROR]: specified --disk '$DISK' is not a block-special file" && exit 4
else
    [ -z "$LFS" ] && export LFS="/lfs"    
fi

if [ -n "$CLEAR" -a $DOCKER_CONTEXT -eq 0 ]; then
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

if [ -n "$INSTALL" -o $DOCKER_CONTEXT -eq 1 ]; then
    echo "================ PREPARE BUILD ENVIRONMENT: MAIN ================"
    CD=$(realpath $0)
    CD=$(dirname $CD)
    cd $CD
    ./1_install_essential_tools.sh
    [ $DOCKER_CONTEXT -eq 0 ] && ./2_prepare_lfs_filesystem.sh "$DISK"
    ./3_prepare_build_environment.sh
    [ $DOCKER_CONTEXT -eq 0 ] && ./4_install_lfs_user.sh
fi
