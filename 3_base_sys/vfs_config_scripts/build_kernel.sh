#no need for shebang because /bin/bash does not exist and this script is being run by bash
SYS_CONF_SCRIPTS_DIR="vfs_config_scripts"
SRC="/sources"

function build_and_install_kernel ()
{

    cd $SRC
    local TG=$(extract linux-5.5.3.tar.xz)
    cd $TG
    
    make mrproper
	#make menuconfig
    local ERR=$?
    cp -v /$SYS_CONF_SCRIPTS_DIR/kernel_build_config .config
    
    if [ $ERR -eq 0 ]; then
        make

        make modules_install

        #copy build artifacts to /boot 
        cp -iv arch/x86/boot/bzImage /boot/vmlinuz-5.5.3-lfs-9.1
        cp -iv System.map /boot/System.map-5.5.3
        cp -iv .config /boot/config-5.5.3

        install -d /usr/share/doc/linux-5.5.3
        cp -r Documentation/* /usr/share/doc/linux-5.5.3
    else
        echo "[ERROR]: make menuconfig failed"
    fi

    rm -v -rf $TG
    cd $SRC
    return $ERR
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

source $WRK/$SYS_CONF_SCRIPTS_DIR/utils.sh
#---------------------------------------------
s_start $0
S=$?

run_cmd build_and_install_kernel
ERROR=$?
run_cmd create_mod_conf_file

s_end $0
E=$?
s_duration $0 $S $E
exit $ERROR