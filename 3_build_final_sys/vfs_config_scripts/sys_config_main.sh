#no need for shebang because /bin/bash does not exist and this script is being run by bash
if [ "$1" == "--docker" ]; then
    SYS_CONF_SCRIPTS_DIR="$WRK/vfs_config_scripts"
else
    SYS_CONF_SCRIPTS_DIR="vfs_config_scripts"
fi

source /$SYS_CONF_SCRIPTS_DIR/utils.sh

echo "================ LFS SYS CONFIGURATION MAIN ================"
s_start $0
S=$?

/$SYS_CONF_SCRIPTS_DIR/bootscripts.sh
/$SYS_CONF_SCRIPTS_DIR/devices_handling_and_network_conf.sh
/$SYS_CONF_SCRIPTS_DIR/sysvinit_and_confs.sh
/$SYS_CONF_SCRIPTS_DIR/build_kernel.sh
/$SYS_CONF_SCRIPTS_DIR/make_lfs_bootable.sh
/$SYS_CONF_SCRIPTS_DIR/set_system_version.sh

s_end $0
E=$?
s_duration $0 $S $E
