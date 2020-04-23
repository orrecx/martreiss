#no need for shebang because /bin/bash does not exist and this script is being run by bash
SYS_CONF_SCRIPTS_DIR="vfs_config_scripts"
SRC="/sources"

function create_lsb_release ()
{
    echo 9.1 > /etc/lfs-release
    cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux OREX LAB"
DISTRIB_RELEASE="9.1"
DISTRIB_CODENAME="orex-lab"
DISTRIB_DESCRIPTION="Linux From Scratch Tuto"
EOF
}

function create_os_release ()
{
    cat > /etc/os-release << "EOF"
NAME="Linux From Scratch"
VERSION="9.1"
ID=lfs
PRETTY_NAME="LFS OREX LAB 9.1"
VERSION_CODENAME="orex-lab"
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
