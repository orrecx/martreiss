#!/bin/bash

if [ -z "$LFS" ]; then
    if [ "$DOCKER_CONTEXT" = "0" ]; then
            LFS="/mnt/lfs"
    else
            LFS="/lfs"
    fi
fi

if [ -z "$LFS_TGT" ]; then
    LFS_TGT="$(uname -m)-lfs-linux-gnu"
fi

if [ -z "$SOURCES_DIR" ]; then
    SOURCES_DIR="$LFS/sources"
fi

if [ -z "$TOOLS_SLINK" ]; then
    TOOLS_SLINK="/tools"
fi

if [ -z "$TOOLS_DIR" ]; then
    TOOLS_DIR="${LFS}${TOOLS_SLINK}"
fi

if [ -z "$COMPONENTS_DIR" ]; then
    COMPONENTS_DIR="components"
fi

if [ -z "$UTILS" ]; then
    UTILS="common"
fi

export LFS LFS_TGT SOURCES_DIR TOOLS_SLINK TOOLS_DIR COMPONENTS_DIR UTILS