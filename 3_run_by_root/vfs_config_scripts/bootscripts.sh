#no need for shebang because /bin/bash does not exist and this script is being run by bash
SYS_CONF_SCRIPTS_DIR="vfs_config_scripts"
SRC="/sources"

source /$SYS_CONF_SCRIPTS_DIR/utils.sh
s_start $0
S=$?

cd $SRC
TG=$(extract lfs-bootscripts-20191031.tar.xz )
cd $TG
make install
cd $SRC
rm -rf $TG

s_end $0
E=$?
s_duration $0 $S $E
