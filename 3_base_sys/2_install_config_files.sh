#!/bin/bash
cd "$( dirname $(realpath $0))"

cp -f -v sys_config_files/bashrc        /root/.bashrc
cp -f -v sys_config_files/profile       /root/.profile
cp -f -v sys_config_files/nsswitch.conf /etc/nsswitch.conf
cp -f -v sys_config_files/ld.so.conf    /etc/ld.so.conf
cp -f -v sys_config_files/vimrc         /etc/vimrc
cp -f -v sys_config_files/syslog.conf   /etc/syslog.conf

exit 0