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

if [ -z "$COMPONENTS_DIR" ]; then
    COMPONENTS_DIR="components"
    export COMPONENTS_DIR
fi