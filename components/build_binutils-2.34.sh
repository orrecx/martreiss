#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
    mkdir -v build
    cd build

	./configure --prefix=$TOOLS_SLINK 		\
                 --with-sysroot=$LFS        \
                 --with-lib-path=/tools/lib \
                 --target=$LFS_TGT          \
                 --disable-nls              \
                 --disable-werror

	make
	make install
}

_build_ext ()
{
    mkdir -v build
    cd       build

    CC=$LFS_TGT-gcc                \
    AR=$LFS_TGT-ar                 \
    RANLIB=$LFS_TGT-ranlib         \
    ../configure                   \
        --prefix=/tools            \
        --disable-nls              \
        --disable-werror           \
        --with-lib-path=/tools/lib \
        --with-sysroot

    make
    make install
    make -C ld clean
    make -C ld LIB_PATH=/usr/lib:/lib
    cp -v ld/ld-new /tools/bin
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="binutils-2.34.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

case "$1" in
  --pass2)
    _build_ext
    ;;
  *)
  _build
  ;;
esac

cd $SRC
rm -v -rf $TG

exit $ERROR
