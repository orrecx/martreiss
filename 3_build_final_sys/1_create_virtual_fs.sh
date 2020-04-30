#!/bin/bash

[ -z "$LFS" -o ! -d "$LFS" ] && \
echo "[ERROR]: Environment variable LFS is not set yet or directory $LFS does not exist yet" && exit 3

if [ -n "$1" ] && [ "$1" = "--clear" -o "$1" = "-c"  ]; then
  _clear
  exit 0
fi

chown -R root:root $LFS/tools
mkdir -pv $LFS/{dev,proc,sys,run}
#create initial device node
mknod -m 600 $LFS/dev/console c 5 1
mknod -m 666 $LFS/dev/null c 1 3
#bind mount system dev to host system dev
mount -v --bind /dev $LFS/dev
#mount type device dir options 
mount -vt devpts devpts $LFS/dev/pts -o gid=5,mode=620
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run
#in case shm is a symbolic link just create a directory
if [ -h $LFS/dev/shm ]; then
  mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi

if [ -d "${LFS}/tools/$(uname -m)-pc-linux-gnu" ]; then
  cp -r ${LFS}/tools/$(uname -m)-pc-linux-gnu ${LFS}/tools/$(uname -m)-lfs-linux-gnu
fi
