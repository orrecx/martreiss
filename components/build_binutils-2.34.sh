#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
    local ERR=0
    mkdir -v build
    cd build

	../configure --prefix=$TOOLS_SLINK 		\
                 --with-sysroot=$LFS        \
                 --with-lib-path=/tools/lib \
                 --target=$LFS_TGT          \
                 --disable-nls              \
                 --disable-werror

	make
	make install
}

_build_round2 ()
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

function _build_ext ()
{
  local ERR=0
  local T=`expect -c "spawn ls"`
  if [[ "$T" = *"spawn"* ]]; then
      sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in
      mkdir -v build
      cd       build
      ../configure --prefix=/usr       \
                   --enable-gold       \
                   --enable-ld=default \
                   --enable-plugins    \
                   --enable-shared     \
                   --disable-werror    \
                   --enable-64-bit-bfd \
                   --with-system-zlib
      make tooldir=/usr
      make -k check
      ERR=$?
      [ $ERR -ne 0 ] && echo "[ERROR]: make check failed"
      make install             
  else
      echo "[ERROR]: expect -c spawn ls failed"
      ERR=1
  fi

  return $ERR
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
    _build_round2
    ;;
  --ext)
    _build_ext
    ERROR=$?
    ;;
  *)
  _build
  ;;
esac

cd $SRC
rm -v -rf $TG

exit $ERROR
