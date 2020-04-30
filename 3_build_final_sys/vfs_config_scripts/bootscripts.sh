#no need for shebang because /bin/bash does not exist and this script is being run by bash
SYS_CONF_SCRIPTS_DIR="vfs_config_scripts"
SRC="/sources"

function install_bootscripts ()
{
    cd $SRC
    local TG=$(extract lfs-bootscripts-20191031.tar.xz )
    cd $TG

    make install

    rm -rf $TG
    cd $SRC
}

source $WRK/$SYS_CONF_SCRIPTS_DIR/utils.sh
#----------------------------

s_start $0
S=$?

run_cmd install_bootscripts

s_end $0
E=$?
s_duration $0 $S $E
