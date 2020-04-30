#no need for shebang because /bin/bash does not exist and this script is being run by bash
SYS_CONF_SCRIPTS_DIR="vfs_config_scripts"
SRC="/sources"

function create_lsb_release ()
{
    echo 1.0 > /etc/lfs-release
    cat > /etc/lsb-release << "EOF"
DISTRIB_ID="MATRISSYS"
DISTRIB_RELEASE="1.0"
DISTRIB_CODENAME="lfs-lab"
DISTRIB_DESCRIPTION="MATRISSYS: Linux sys based on Linux From Scratch Tuto Version 9.1"
EOF
}

function create_os_release ()
{
    cat > /etc/os-release << "EOF"
NAME="matrissys"
VERSION="1.0"
ID=lfs-lab
PRETTY_NAME="matrissys lfs-lab 1.0"
VERSION_CODENAME="lfs-lab"
EOF
}

source /$SYS_CONF_SCRIPTS_DIR/utils.sh
#---------------------------------------------
s_start $0
S=$?

run_cmd create_lsb_release
run_cmd create_os_release

s_end $0
E=$?
s_duration $0 $S $E
