#!/bin/bash
cd "$( dirname $(realpath $0))"

source ../common/config.sh
source ../common/utils.sh
#---------------------------------------------
BUILD_SCRIPT_DIR="../$COMPONENTS_DIR"

s_start $0
S=$?

$BUILD_SCRIPT_DIR/build_lfs-bootscripts-20191031.sh

s_end $0
E=$?
s_duration $0 $S $E
