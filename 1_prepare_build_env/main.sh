#!/bin/bash
cd "$( dirname $(realpath $0))"

INSTALL=
CLEAR=
DISK=
DOCKER_CONTEXT=0

#------------------------------------------------
function _help ()
{
    echo "USAGE: $(basename $0) -i|--install|--docker|-c|--clear|--disk <disk>" 
}

#------------------------------------------------
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

source ../common/config.sh
source ../common/utils.sh

if [ $DOCKER_CONTEXT -eq 0 ]; then
    [ $(id --user) -ne 0 ] && echo "[ERROR]: only root is allowed to run this script. use sudo" && exit 1
    [ ! -b "$DISK" ] && echo "[ERROR]: specified --disk '$DISK' is not a block-special file" && exit 4
fi

if [ $DOCKER_CONTEXT -eq 0 ]; then
    if [ -n "$CLEAR" ]; then
        echo "================ MAIN: CLEAR ================"
        chown -v -R root:root $LFS
        echo "userdel lfs"
        userdel lfs
        for D in $(ls -1 $LFS | grep -v lost ); do rm -rvf $D; done
        rm -vf /tools
        pushd /bin
        ln -v -s -f /usr/bin/dash sh
        popd
        umount -v $LFS
        [ -e "/etc/fstab.backup" ] && mv -v /etc/fstab.backup /etc/fstab
        [ -e "/root/.bashrc.backup" ] && mv -v /root/.bashrc.backup  /root/.bashrc
        ( echo "p"; echo "d"; echo ""; echo "w" ) | fdisk $DISK
        echo "wait..."
        sleep 2
    fi

    if [ -n "$INSTALL" ]; then
        echo "================ PREPARE BUILD ENVIRONMENT: MAIN ================"
        ./1_install_essential_tools.sh
        ./2_prepare_lfs_filesystem.sh "$DISK"
        ./3_get_sources.sh
        ./4_install_lfs_user.sh
    fi
else
    echo "================ PREPARE BUILD ENVIRONMENT: MAIN ================"
    ./1_install_essential_tools.sh
    ./3_get_sources.sh
fi