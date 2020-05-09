#!/bin/bash
cd "$( dirname $(realpath $0))"
ERROR=0

function _build () 
{
	local ERR=0
    tar -xf ../mpfr-4.0.2.tar.xz
    mv -v mpfr-4.0.2 mpfr
    tar -xf ../gmp-6.2.0.tar.xz
    mv -v gmp-6.2.0 gmp
    tar -xf ../mpc-1.1.0.tar.gz
    mv -v mpc-1.1.0 mpc

    for file in gcc/config/{linux,i386/linux{,64}}.h
    do
      cp -uv $file{,.orig}
      sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
          -e 's@/usr@/tools@g' $file.orig > $file
      echo '
    #undef STANDARD_STARTFILE_PREFIX_1
    #undef STANDARD_STARTFILE_PREFIX_2
    #define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
    #define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
      touch $file.orig
    done

    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

    mkdir -v build
    cd       build
    ../configure                                       \
        --target=$LFS_TGT                              \
        --prefix=/tools                                \
        --with-glibc-version=2.11                      \
        --with-sysroot=$LFS                            \
        --with-newlib                                  \
        --without-headers                              \
        --with-local-prefix=/tools                     \
        --with-native-system-header-dir=/tools/include \
        --disable-nls                                  \
        --disable-shared                               \
        --disable-multilib                             \
        --disable-decimal-float                        \
        --disable-threads                              \
        --disable-libatomic                            \
        --disable-libgomp                              \
        --disable-libquadmath                          \
        --disable-libssp                               \
        --disable-libvtv                               \
        --disable-libstdcxx                            \
        --enable-languages=c,c++

    make
    make install
}

function _build_Libstdcxx ()
{
    mkdir -v build
    cd       build
    ../libstdc++-v3/configure           \
        --host=$LFS_TGT                 \
        --prefix=/tools                 \
        --disable-multilib              \
        --disable-nls                   \
        --disable-libstdcxx-threads     \
        --disable-libstdcxx-pch         \
        --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/9.2.0
    make
    make install
    return 0
}

function _build_round2 ()
{
    local ERR=0
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
      `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

    for file in gcc/config/{linux,i386/linux{,64}}.h
    do
      cp -uv $file{,.orig}
      sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
          -e 's@/usr@/tools@g' $file.orig > $file
      echo '
    #undef STANDARD_STARTFILE_PREFIX_1
    #undef STANDARD_STARTFILE_PREFIX_2
    #define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
    #define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
      touch $file.orig
    done

    case $(uname -m) in
      x86_64)
        sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
        ;;
    esac

    tar -xf ../mpfr-4.0.2.tar.xz
    mv -v mpfr-4.0.2 mpfr
    tar -xf ../gmp-6.2.0.tar.xz
    mv -v gmp-6.2.0 gmp
    tar -xf ../mpc-1.1.0.tar.gz
    mv -v mpc-1.1.0 mpc

    sed -e '1161 s|^|//|' \
        -i libsanitizer/sanitizer_common/sanitizer_platform_limits_posix.cc

    mkdir -v build
    cd       build

    CC=$LFS_TGT-gcc                                    \
    CXX=$LFS_TGT-g++                                   \
    AR=$LFS_TGT-ar                                     \
    RANLIB=$LFS_TGT-ranlib                             \
    ../configure                                       \
        --prefix=$TOOLS_SLINK                                \
        --with-local-prefix=$TOOLS_SLINK                     \
        --with-native-system-header-dir=$TOOLS_SLINK/include \
        --enable-languages=c,c++                       \
        --disable-libstdcxx-pch                        \
        --disable-multilib                             \
        --disable-bootstrap                            \
        --disable-libgomp

    make
    make install
    ln -sv gcc $TOOLS_SLINK/bin/cc

	if [ "$1" == "--test" ]; then
	    #sanitiy check: check if compiling and linking works as expected
    echo 'int main(){}' > dummy.c
    cc dummy.c
    readelf -l a.out | grep ': /tools'
    ERR=$?
    [ $ERR -ne 0 ] && echo "[ERROR]: tool chain does not work properly"
	fi
	return $ERR
}

function _build_ext ()
{
  case $(uname -m) in
    x86_64)
      sed -e '/m64=/s/lib64/lib/' \
          -i.orig gcc/config/i386/t-linux64
      ;;
  esac
  sed -e '1161 s|^|//|' \
      -i libsanitizer/sanitizer_common/sanitizer_platform_limits_posix.cc

  mkdir -v build
  cd       build

  SED=sed                               \
  ../configure --prefix=/usr            \
               --enable-languages=c,c++ \
               --disable-multilib       \
               --disable-bootstrap      \
               --with-system-zlib

  make
  ulimit -s 32768

  chown -Rv nobody . 
  su nobody -s /bin/bash -c "PATH=$PATH make -k check"
  ../contrib/test_summary

  make install

  rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/9.2.0/include-fixed/bits/
  chown -v -R root:root /usr/lib/gcc/*linux-gnu/9.2.0/include{,-fixed}
  ln -sv ../usr/bin/cpp /lib
  ln -sv gcc /usr/bin/cc
  install -v -dm755 /usr/lib/bfd-plugins
  ln -svf ../../libexec/gcc/$(gcc -dumpmachine)/9.2.0/liblto_plugin.so \
          /usr/lib/bfd-plugins/
  
  echo 'int main(){}' > dummy.c
  cc dummy.c -v -Wl,--verbose &> dummy.log
  readelf -l a.out | grep ': /lib'
  local ERR=$?
  if [ $ERR -eq 0 ]; then
      grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
      #expected result:
      #/usr/lib/gcc/x86_64-pc-linux-gnu/9.2.0/../../../../lib/crt1.o succeeded
      #/usr/lib/gcc/x86_64-pc-linux-gnu/9.2.0/../../../../lib/crti.o succeeded
      #/usr/lib/gcc/x86_64-pc-linux-gnu/9.2.0/../../../../lib/crtn.o succeeded
      grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
      #expected result:
      #SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib64")
      #SEARCH_DIR("/usr/local/lib64")
      #SEARCH_DIR("/lib64")
      #SEARCH_DIR("/usr/lib64")
      #SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib")
      #SEARCH_DIR("/usr/local/lib")
      #SEARCH_DIR("/lib")
      #SEARCH_DIR("/usr/lib");                    
  else
      echo "[ERROR]: fail to build gcc."
  fi

  mkdir -pv /usr/share/gdb/auto-load/usr/lib
  mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

  return $ERR
}

source ../common/config.sh
source ../common/utils.sh
#----------------------------------------
echo "-------------------- $0 --------------------"
SRC=$SOURCES_DIR
COMP="gcc-9.2.0.tar.xz"

cd $SRC
TG=$( extract $COMP )
cd $TG

case "$1" in
  --libstdcxx)
    _build_Libstdcxx
    ;;
  --pass2)
  _build_round2 --test
  ERROR=$?
  ;;
  --ext)
  _build_ext --test
  ERROR=$?
  *)
  _build
  ERROR=$?
  ;;
esac

cd $SRC
rm -v -rf $TG

exit $ERROR
