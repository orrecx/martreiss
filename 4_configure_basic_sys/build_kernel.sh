#!/bin/bash
cd "$( dirname $(realpath $0))"


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

source ../common/config.sh
source ../common/utils.sh
#---------------------------------------------
BUILD_SCRIPT_DIR="../$COMPONENTS_DIR"

s_start $0
S=$?

$BUILD_SCRIPT_DIR/build_linux-5.5.3.sh  --kernel --config $(pwd)/sys_config_files/kernel_build_config
ERROR=$?
run_cmd create_mod_conf_file


s_end $0
E=$?
s_duration $0 $S $E
exit $ERROR