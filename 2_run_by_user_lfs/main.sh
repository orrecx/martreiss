#!/bin/bash -x
function delete_unecessary_files ()
{
    echo "Don't do this because it will damage the compile environment"
    
    #echo "function delete_unecessary_files..."
    #find $LFS/tools/{lib,libexec} -name \*.la -delete 
    #rm -v -rf $LFS/tools/{,share}/{info,man,doc}
}

function archive_artefact ()
{
    echo "archive_artefact.."
    tar cvf $LFS/tools.tar $LFS/tools
    gzip -v $LFS/tools.tar
}

U="lfs"
id -u $U
[ $? -ne 0 ] && echo "[ERROR]: a user $U is required" && exit 1
[ "$(id -u)" -ne $(id -u $U) ] && echo "[ERROR]: run this script as user $U" && exit 2
[ -z "$LFS" -o ! -d "$LFS" ] && \
echo "[ERROR]: Environment variable LFS is not set yet or directory $LFS does not exist yet" && exit 3
[ -z "$LFS_TGT" ] && echo "[ERROR]: Environment variable LFS_TGT is not set yet"

CD=$(realpath $0)
CD=$(dirname $CD)
cd $CD
echo "================ MAIN: CONSTRUCT MINIMAL SYSTEM ================"
export MAKEFLAGS='-j 2'
env -i HOME=$HOME TERM=$TERM LFS=$LFS LFS_TGT=$LFS_TGT PATH=$PATH 'PS1=(limited)\u:\w\$' /bin/bash -c ./build.sh
if [ $? -eq 0 ]; then
    #delete_unecessary_files
    archive_artefact
    #./backup_build_state.sh
else
    echo "[ERROR]: build failed"
    exit 4
fi