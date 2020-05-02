#!/bin/bash
#-------------------
echo "---------------- $0 ---------------------"
[ ! -d "$LFS" ] && echo "[ERROR]: Directory $LFS does not exist yet." && exit 1
#create build directories
mkdir -vp $LFS/{sources,tools}
SRC="$LFS/sources"
chmod -v a+wt $SRC
ln -sv $LFS/tools /
[ ! -f "$SRC/wget-list" ] && wget   -v --continue --directory-prefix=$SRC \
                                    http://www.linuxfromscratch.org/lfs/view/stable/wget-list

cat $SRC/wget-list
wget -v --input-file="$SRC/wget-list" --continue --directory-prefix=$SRC
#the path to openssl is wrong
wget -v -c --directory-prefix=$SRC https://www.openssl.org/source/old/1.1.1/openssl-1.1.1d.tar.gz

if [ "$1" == "--check" ]; then
    wget -v -c --directory-prefix=$SRC http://www.linuxfromscratch.org/lfs/view/stable/md5sums
    pushd $SRC
    md5sum -c md5sums
    [ $? -ne 0 ] && echo "[ERROR]: checking source files integrity failed" && exit 1
    popd
fi

pushd $LFS/tools
mkdir -v lib
case $(uname -m) in
    x86_64) ln -v -s lib lib64 ;;
esac
popd