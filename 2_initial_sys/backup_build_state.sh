#!/bin/bash
#template
[ -z "$LFS" -o ! -d "$LFS/tools" ] && \
echo "[ERROR]: Environment variable LFS is not set yet or directory $LFS does not exist yet" && exit 3

echo "backing up $LFS/tools.tar.gz..."