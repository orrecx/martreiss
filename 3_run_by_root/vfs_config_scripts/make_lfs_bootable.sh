#no need for shebang because /bin/bash does not exist and this script is being run by bash
SYS_CONF_SCRIPTS_DIR="vfs_config_scripts"
SRC="/sources"

function create_fstab ()
{
cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/sda1      /            ext4     defaults            1     1
#/dev/<yyy>     swap         swap     pri=1               0     0
proc           /proc        proc     nosuid,noexec,nodev 0     0
sysfs          /sys         sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts     devpts   gid=5,mode=620      0     0
tmpfs          /run         tmpfs    defaults            0     0
devtmpfs       /dev         devtmpfs mode=0755,nosuid    0     0

# End /etc/fstab
EOF
}

function build_and_install_kernel ()
{

    cd $SRC
    local TG=$(extract linux-5.5.3.tar.xz)
    cd $TG

    make mrproper
	#make menuconfig
    make modules_install
    cp -iv arch/x86/boot/bzImage /boot/vmlinuz-5.5.3-lfs-9.1
    cp -iv System.map /boot/System.map-5.5.3
    cp -iv .config /boot/config-5.5.3
    install -d /usr/share/doc/linux-5.5.3
    cp -r Documentation/* /usr/share/doc/linux-5.5.3

    cd $SRC
    chown -R 0:0 $TG
}

function create_mod_conf_file ()
{
    install -v -m755 -d /etc/modprobe.d
    cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
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
set root=(hd0,2)

menuentry "GNU/Linux, Linux 5.5.3-lfs-9.1" {
        linux   /boot/vmlinuz-5.5.3-lfs-9.1 root=/dev/sdb1 ro
}
EOF
}

source /$SYS_CONF_SCRIPTS_DIR/utils.sh
#---------------------------------------------
s_start $0
S=$?

run_cmd create_fstab
run_cmd build_and_install_kernel
run_cmd create_mod_conf_file
#run_cmd grub_and_boot_process

s_end $0
E=$?
s_duration $0 $S $E
