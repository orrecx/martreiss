#!/bin/bash
cd "$( dirname $(realpath $0))"

function create_virtual_kernel_filesystem ()
{
  mkdir -pv /{dev,proc,sys,run}
  #create initial device node
  mknod -m 600 /dev/console c 5 1
  mknod -m 666 /dev/null c 1 3
  #mount type device dir options 
  mount -vt devpts devpts /dev/pts -o gid=5,mode=620
  mount -vt proc proc /proc
  mount -vt sysfs sysfs /sys
  mount -vt tmpfs tmpfs /run
  #in case shm is a symbolic link just create a directory
  if [ -h /dev/shm ]; then
    mkdir -pv /$(readlink /dev/shm)
  fi

  if [ -d "/tools/$(uname -m)-pc-linux-gnu" ]; then
    cp -v -r /tools/$(uname -m)-pc-linux-gnu /tools/$(uname -m)-lfs-linux-gnu
  fi
}

function create_directory_structure ()
{
  mkdir -pv /{bin,boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}
  mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}
  install -dv -m 0750 /root
  install -dv -m 1777 /tmp /var/tmp
  mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
  mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
  mkdir -v  /usr/{,local/}share/{misc,terminfo,zoneinfo}
  mkdir -v  /usr/libexec
  mkdir -pv /usr/{,local/}share/man/man{1..8}
  mkdir -v  /usr/lib/pkgconfig

  case $(uname -m) in
   x86_64) mkdir -v /lib64 ;;
  esac

  mkdir -v /var/{log,mail,spool}
  ln -sv /run /var/run
  ln -sv /run/lock /var/lock
  mkdir -pv /var/{opt,cache,lib/{color,misc,locate},local}

  #create symblinks for tools that do not exist yet at the expected location
  ln -sv /tools/bin/{bash,cat,chmod,dd,echo,ln,mkdir,pwd,rm,stty,touch,ls} /bin
  ln -sv /tools/bin/{env,install,perl,printf}         /usr/bin
  ln -sv /tools/lib/libgcc_s.so{,.1}                  /usr/lib
  ln -sv /tools/lib/libstdc++.{a,so{,.6}}             /usr/lib

  ln -sv bash /bin/sh

  ln -sv /proc/self/mounts /etc/mtab
  ln -sv /tools/sbin/{zic,ldconfig,csd,sln} /sbin

  mkdir -vp /etc/ld.so.conf.d
}

function create_user_admin_files ()
{
  echo "create /etc/passwd"
  cp -v sys_config_files/passwd /etc/passwd
  echo "create /etc/group"
  cp -v sys_config_files/group /etc/group
}

function create_logfiles ()
{
  touch /var/log/{btmp,lastlog,faillog,wtmp}
  chgrp -v utmp /var/log/lastlog
  chmod -v 664  /var/log/lastlog
  chmod -v 600  /var/log/btmp
}

source ../common/config.sh
source ../common/utils.sh
#------------------------------------------------
[ "x$DOCKER_CONTEXT" == "x" ] && DOCKER_CONTEXT=0
case "$1" in
--docker) DOCKER_CONTEXT=1 ;;
esac

if [ $DOCKER_CONTEXT -eq 0 ]; then
  [ -z "$LFS" -o ! -d "$LFS" ] && \
  echo "[ERROR]: Environment variable LFS is not set yet or directory $LFS does not exist yet" && exit 3

  if [ -n "$1" ] && [ "$1" = "--clear" -o "$1" = "-c"  ]; then
    _clear
    exit 0
  fi

  chown -R root:root $LFS/tools
else
  LFS=""
fi


run_cmd create_virtual_kernel_filesystem
run_cmd create_directory_structure
run_cmd create_user_admin_files
run_cmd create_logfiles

