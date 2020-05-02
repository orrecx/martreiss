#!/bin/bash

function create_partition ()
{
    ( echo n; echo ""; echo ""; echo ""; echo N; echo ""; echo w ) | fdisk $1
    echo "wait..."
    sleep 3
}

function create_fs_mount_and_populate_fstab () 
{    
    ( echo "Y" ) | mkfs -v -t ext4 "$1"
    UUID=$(blkid | grep "$1" | awk '{print $2}')
    echo "$UUID"
    mount -v -t ext4 $1 $LFS 

    if [[ $UUID = *"UUID"* ]]; then
        UUID=$( echo $UUID | cut -d'"' -f2 )
        [ ! -f "/etc/fstab.backup" ] && cp /etc/fstab /etc/fstab.backup
        echo -e "UUID=$UUID \t $LFS \t ext4 \t defaults \t 1 \t 1" >> /etc/fstab
    fi
}

#----- main -----
echo "---------------- $0 ---------------------"
[ -z "$LFS" ] && echo "[ERROR]: Environment variable LFS is not set yet." && exit 1
[ $(id --user) -ne 0 ] && echo "[ERROR]: only root is allowed to run this script. use sudo" && exit 3
[ -z "$1" ] && echo "[ERROR]: no disk (ex: /dev/sdb) specified." && exit 2

DSK="$1"
mkdir -vp $LFS
chmod o+w -R $LFS

create_partition $DSK
create_fs_mount_and_populate_fstab  "${DSK}1"

[ ! -e "/root/.bashrc.backup" ] && cp /root/.bashrc /root/.bashrc.backup
echo "export LFS=$LFS" >> /root/.bashrc
