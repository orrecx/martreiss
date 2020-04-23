SRC="/sources"

#------------------------------------------------
function install_linux_headers()
{
    cd $SRC
    local TG=$(extract linux-5.5.3.tar.xz )
    cd $TG

    make mrproper

    make headers
    find usr/include -name '.*' -delete
    rm usr/include/Makefile
    cp -rv usr/include/* /usr/include

    cd $SRC
    rm -rf $TG
}

function install_man_pages()
{
    cd $SRC
    local TG=$(extract man-pages-5.05.tar.xz )
    cd $TG

    make install

    cd $SRC
    rm -rf $TG
}

function build_and_install_glibc ()
{
    cd $SRC
    local TG=$(extract glibc-2.31.tar.xz )
    cd $TG

    patch -Np1 -i ../glibc-2.31-fhs-1.patch
    case $(uname -m) in
        i?86)   ln -svf ld-linux.so.2 /lib/ld-lsb.so.3
        ;;
        x86_64) ln -svf ../lib/ld-linux-x86-64.so.2 /lib64
                ln -svf ../lib/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
        ;;
    esac

    mkdir -v build
    cd       build
    CC="gcc -ffile-prefix-map=/tools=/usr" \
    ../configure --prefix=/usr                          \
                 --disable-werror                       \
                 --enable-kernel=3.2                    \
                 --enable-stack-protector=strong        \
                 --with-headers=/usr/include            \
                 libc_cv_slibdir=/lib

    make
    case $(uname -m) in
      i?86)   ln -sfnv $PWD/elf/ld-linux.so.2        /lib ;;
      x86_64) ln -sfnv $PWD/elf/ld-linux-x86-64.so.2 /lib ;;
    esac
    make check
    touch /etc/ld.so.conf
    sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
    make install
    cp -v ../nscd/nscd.conf /etc/nscd.conf
    mkdir -pv /var/cache/nscd

    mkdir -pv /usr/lib/locale
    make localedata/install-locales
#configure glibc
##nsswitch
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF
##timezone
    tar -xzf ../../tzdata2019c.tar.gz

    ZONEINFO=/usr/share/zoneinfo
    mkdir -pv $ZONEINFO/{posix,right}
    
    for tz in etcetera southamerica northamerica europe africa antarctica  \
              asia australasia backward pacificnew systemv; do
        zic -L /dev/null   -d $ZONEINFO       ${tz}
        zic -L /dev/null   -d $ZONEINFO/posix ${tz}
        zic -L leapseconds -d $ZONEINFO/right ${tz}
    done

    cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
    #zic -d $ZONEINFO -p America/New_York
    zic -d $ZONEINFO -p Europe/Berlin
    ln -svf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
    unset ZONEINFO

    cd $SRC
    rm -rf $TG
# dynamic loader
cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF
    mkdir -pv /etc/ld.so.conf.d    
}

source /vfs_scripts/utils.sh
#--------------- main ---------------------------
s_start $0
ST=$?

run_cmd install_linux_headers
run_cmd install_man_pages
run_cmd build_and_install_glibc

s_end $0
ED=$?
s_duration $0 $ST $ED
