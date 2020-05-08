#!/bin/bash
[ -z "$LFS" ] && echo "[ERROR]: LFS not set" && exit 1

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
exit 0