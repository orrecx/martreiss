#!/bin/bash
#-------------------
echo "---------------- $0 ---------------------"
[ ! -d "$LFS" ] && echo "[ERROR]: Directory $LFS does not exist yet." && exit 1
#create build directories
mkdir -v $LFS/{sources,tools}
SRC="$LFS/sources"
chmod -v a+wt $SRC
ln -sv $LFS/tools /
[ ! -f "wget-list" ] && wget -c http://www.linuxfromscratch.org/lfs/view/stable/wget-list -o $LFS/wget-list
wget --input-file="$LFS/wget-list" --continue --directory-prefix=$SRC
#the path to openssl is wrong
cd $SRC
wget -c https://www.openssl.org/source/old/1.1.1/openssl-1.1.1d.tar.gz
cd -
pushd $(pwd)
cd /tools
mkdir -v lib
case $(uname -m) in
    x86_64) ln -v -s lib lib64 ;;
esac
popd