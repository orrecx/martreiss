#!/bin/bash
cd "$( dirname $(realpath $0))"

function create_fstab ()
{
    cp -v sys_config_files/fstab /etc/fstab
}

function _install_grub ()
{
    grub-install /dev/sdb
    cp -v sys_config_files/grub.cfg /boot/grub/grub.cfg
}

#---------------------------------------------
s_start $0
S=$?

run_cmd create_fstab
run_cmd _install_grub

s_end $0
E=$?
s_duration $0 $S $E
