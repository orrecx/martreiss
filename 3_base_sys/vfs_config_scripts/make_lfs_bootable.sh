#no need for shebang because /bin/bash does not exist and this script is being run by bash
SYS_CONF_SCRIPTS_DIR="vfs_config_scripts"
SRC="/sources"

function create_fstab ()
{
    mkdir -pv /ublab
cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type        options                dump  fsck order

/dev/sdb1      /            ext4        defaults               1     1
/dev/sda1      /ublab       ext4        defaults               1     0
#/dev/<yyy>     swap        swap        pri=1                  0     0
proc           /proc        proc        nosuid,noexec,nodev    0     0
sysfs          /sys         sysfs       nosuid,noexec,nodev    0     0
devpts         /dev/pts     devpts      gid=5,mode=620         0     0
tmpfs          /run         tmpfs       defaults               0     0
devtmpfs       /dev         devtmpfs    mode=0755,nosuid       0     0

# End /etc/fstab
EOF
}

function grub_and_boot_process ()
{
    grub-install /dev/sdb
cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod ext2

#the current system has 2 disks and 1 partition on each
#the lfs sys is actually hosted on the first partition of the second disk hence (hd1,1)
set root=(hd1,1)

menuentry "GNU/Linux, Linux 5.5.3-lfs-9.1" {
        matrissys   /boot/vmlinuz-5.5.3-lfs-9.1 root=/dev/sdb1 ro
}
EOF
}

source $WRK/$SYS_CONF_SCRIPTS_DIR/utils.sh
#---------------------------------------------
s_start $0
S=$?

run_cmd create_fstab
run_cmd grub_and_boot_process

s_end $0
E=$?
s_duration $0 $S $E
