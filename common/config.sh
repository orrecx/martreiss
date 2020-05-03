#!/bin/bash

if [ -z "$LFS" ]; then
    if [ "$DOCKER_CONTEXT" = "0" ]; then
            LFS="/mnt/lfs"
    else
            LFS="/lfs"
    fi
    export LFS
fi

if [ -z "$LFS_TGT" ]; then
    LFS_TGT="$(uname -m)-lfs-linux-gnu"
    export LFS_TGT
fi

if [ -z "$SOURCES_DIR" ]; then
    SOURCES_DIR="$LFS/sources"
    export SOURCES_DIR
fi

if [ -z "$TOOLS_SLINK" ]; then
    TOOLS_SLINK="/tools"
    export TOOLS_SLINK
fi

if [ -z "$TOOLS_DIR" ]; then
    TOOLS_DIR="${LFS}${TOOLS_SLINK}"
    export TOOLS_DIR
fi

if [ -z "$COMPONENTS_DIR" ]; then
    COMPONENTS_DIR="components"
    export COMPONENTS_DIR
fi

if [ -z "$UTILS" ]; then
    UTILS="common"
    export UTILS
fi

BACKYARD="backyard"
