#!/bin/bash
cd "$( dirname $(realpath $0))"

source ../common/config.sh
source ../common/utils.sh
#-------------------
s_start $0
START_TIME=$?

mkdir -vp $SOURCES_DIR
mkdir -vp $TOOLS_DIR
SRC=$SOURCES_DIR

chmod -v a+wt $SRC
ln -sv $TOOLS_DIR /

if [ -f "../$BACKYARD/sources.tar.gz" ]; then
    echo "found sources.tar.gz in directory $BACKYARD"
    pushd ../$BACKYARD
    tar xzf sources.tar.gz
    mv -v sources/* $SRC
    popd
else
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
fi
pushd $TOOLS_DIR
mkdir -v lib
case $(uname -m) in
    x86_64) ln -v -s lib lib64 ;;
esac
popd

s_end $0
END_TIME=$?
s_duration $0 $START_TIME $END_TIME 
