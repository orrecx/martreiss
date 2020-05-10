#!/bin/bash
cd "$( dirname $(realpath $0))"

source ../common/config.sh
source ../common/utils.sh
#-----------------------------------

echo "================ CONFIGURE BASIC SYS ================"
s_start $0
S=$?

./bootscripts.sh
./install_configs.sh
./build_kernel.sh
./make_lfs_bootable.sh

s_end $0
E=$?
s_duration $0 $S $E
