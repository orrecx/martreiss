#!/bin/bash
cd "$( dirname $(realpath $0))"

function create_fstab ()
{
    mkdir -pv /ublab
    cp -v sys_config_files/fstab /etc/fstab
}

function grub_and_boot_process ()
{
    grub-install /dev/sdb
    cp -v sys_config_files/fstab /boot/grub/grub.cfg
}

#---------------------------------------------
s_start $0
S=$?

run_cmd create_fstab
run_cmd grub_and_boot_process

s_end $0
E=$?
s_duration $0 $S $E
