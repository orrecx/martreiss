source $WRK/vfs_scripts/utils.sh

echo "================ NEW BASH ================"
s_start $0
S=$?

/vfs_scripts/10_common_tools.sh

s_end $0
E=$?
s_duration $0 $S $E
