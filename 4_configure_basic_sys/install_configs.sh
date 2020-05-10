#!/bin/bash
cd "$( dirname $(realpath $0))"

function install_sys_config_files ()
{
    cp -v sys_config_files/inittab /etc/inittab
    cp -v sys_config_files/profile /etc/profile
    cp -v sys_config_files/shells /etc/shells
    cp -v sys_config_files/inputrc /etc/inputrc

    cp -v sys_config_files/matrissys-release /etc/matrissys-release
    cp -v sys_config_files/os-release /etc/os-release

    mkdir -v -p /etc/sysconfig
    cp -v sys_config_files/clock /etc/sysconfig/clock
    cp -v sys_config_files/console /etc/sysconfig/console
    cp -v sys_config_files/rc.site /etc/sysconfig/rc.site

}

function install_network_config_files ()
{
    cp -v sys_config_files/hosts /etc/hosts
    cp -v sys_config_files/hostname /etc/hostname
    cp -v sys_config_files/resolv.conf /etc/resolv.conf

    mkdir -v -p /etc/sysconfig
    cp -v sys_config_files/ifconfig.eth0 /etc/sysconfig/ifconfig.eth0
}


function create_udev_rules ()
{
    bash /lib/udev/init-net-rules.sh
    #cat /etc/udev/rules.d/70-persistent-net.rules
}

source ../common/config.sh
source ../common/utils.sh
#--------------------------------------------
s_start $0
S=$?

run_cmd create_udev_rules
run_cmd install_network_config_files
run_cmd install_sys_config_files

s_end $0
E=$?
s_duration $0 $S $E
