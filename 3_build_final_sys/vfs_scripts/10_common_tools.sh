SRC="/sources"

#------------------------------------------------
function install_libtool ()
{
    cd $SRC
    build_generic "libtool-2.4.6.tar.xz"
    return $?
}

function install_gdbm ()
{
    cd $SRC
    local TG=$(extract gdbm-1.18.1.tar.gz )
    cd $TG

    ./configure --prefix=/usr    \
                --disable-static \
                --enable-libgdbm-compat
    make
    make check
    local ERR=$?
    make install

    rm -rf $TG
    cd $SRC
    return $ERR
}

function install_gperf ()
{
    cd $SRC
    local TG=$(extract gperf-3.1.tar.gz )
    cd $TG

    ./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
    make
    make -j1 check
    make install

    rm -rf $TG
    cd $SRC
    return $ERR
}

function install_expat ()
{
    cd $SRC
    local TG=$(extract expat-2.2.9.tar.xz )
    cd $TG

    sed -i 's|usr/bin/env |bin/|' run.sh.in
    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/expat-2.2.9
    make
    make check
    local ERR=$?
    make install
    install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.9

    rm -rf $TG
    cd $SRC
    return $ERR
}

function install_inetutils ()
{
    cd $SRC
    local TG=$(extract inetutils-1.9.4.tar.xz )
    cd $TG

    ./configure --prefix=/usr        \
                --localstatedir=/var \
                --disable-logger     \
                --disable-whois      \
                --disable-rcp        \
                --disable-rexec      \
                --disable-rlogin     \
                --disable-rsh        \
                --disable-servers
    
    make
    make check
    make install
    local ERR=$?
    mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
    mv -v /usr/bin/ifconfig /sbin

    rm -rf $TG
    cd $SRC
    return $ERR
}

function install_perl ()
{
    cd $SRC
    local TG=$(extract perl-5.30.1.tar.xz )
    cd $TG

    echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
    export BUILD_ZLIB=False
    export BUILD_BZIP2=0
    sh Configure -des -Dprefix=/usr                 \
                      -Dvendorprefix=/usr           \
                      -Dman1dir=/usr/share/man/man1 \
                      -Dman3dir=/usr/share/man/man3 \
                      -Dpager="/usr/bin/less -isR"  \
                      -Duseshrplib                  \
                      -Dusethreads
    make
    make test
    local ERR=$?
    make install
    unset BUILD_ZLIB BUILD_BZIP2				  

    rm -rf $TG
    cd $SRC
    return $ERR
}

function install_xml-parser ()
{
    cd $SRC
    local TG=$(extract XML-Parser-2.46.tar.gz )
    cd $TG

    perl Makefile.PL
    make
    make test
    local ERR=$?
    make install

    rm -rf $TG
    cd $SRC
    return $ERR
}

function install_intltools ()
{
    cd $SRC
    local TG=$(extract intltool-0.51.0.tar.gz )
    cd $TG

    sed -i 's:\\\${:\\\$\\{:' intltool-update.in
    ./configure --prefix=/usr
    make
    make check
    local ERR=$?
    make install
    install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

    rm -rf $TG
    cd $SRC
    return $ERR
}

function install_autconf ()
{
    cd $SRC
    local TG=$(extract autoconf-2.69.tar.xz )
    cd $TG

    sed '361 s/{/\\{/' -i bin/autoscan.in
    make
    make check
    local ERR=$?
    make install

    rm -rf $TG
    cd $SRC
    return $ERR
}

function install_automake ()
{
    cd $SRC
    local TG=$(extract automake-1.16.1.tar.xz )
    cd $TG

    ./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.1
    make
    make -j4 check
    local ERR=$?
    make install

    rm -rf $TG
    cd $SRC
    return $ERR
}

function install_kmod ()
{
    cd $SRC
    local TG=$(extract kmod-26.tar.xz )
    cd $TG

    ./configure --prefix=/usr          \
                --bindir=/bin          \
                --sysconfdir=/etc      \
                --with-rootlibdir=/lib \
                --with-xz              \
                --with-zlib
    make
    make install

    for target in depmod insmod lsmod modinfo modprobe rmmod; do
      ln -svf ../bin/kmod /sbin/$target
    done

    ln -svf kmod /bin/lsmod			

    rm -rvf $TG
    cd $SRC
}

function install_gettext ()
{
    cd $SRC
    local TG=$(extract gettext-0.20.1.tar.xz )
    cd $TG

    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/gettext-0.20.1
    make
    make check
    local ERR=$?
    make install
    chmod -v 0755 /usr/lib/preloadable_libintl.so

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_elfutils ()
{
    cd $SRC
    local TG=$(extract elfutils-0.178.tar.bz2 )
    cd $TG

    ./configure --prefix=/usr --disable-debuginfod
    make
    make check
    local ERR=$?
    make -C libelf install
    install -vm644 config/libelf.pc /usr/lib/pkgconfig
    rm /usr/lib/libelf.a

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_libffi ()
{
    cd $SRC
    local TG=$(extract libffi-3.3.tar.gz)
    cd $TG
    
    make_generic --prefix=/usr --disable-static --with-gcc-arch=native
    local ERR=$?

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_openssl ()
{
    cd $SRC
    local TG=$(extract openssl-1.1.1d.tar.gz)
    cd $TG

    ./config --prefix=/usr         \
             --openssldir=/etc/ssl \
             --libdir=lib          \
             shared                \
             zlib-dynamic

    sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
    make MANSUFFIX=ssl install
    mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1d
    cp -vfr doc/* /usr/share/doc/openssl-1.1.1d

    rm -rvf $TG
    cd $SRC
}

function install_python ()
{
    cd $SRC
    local TG=$(extract Python-3.8.1.tar.xz)
    cd $TG

    ./configure --prefix=/usr       \
                --enable-shared     \
                --with-system-expat \
                --with-system-ffi   \
                --with-ensurepip=yes
    make
    make install
    chmod -v 755 /usr/lib/libpython3.8.so
    chmod -v 755 /usr/lib/libpython3.so
    ln -svf pip3.8 /usr/bin/pip3			

    install -v -dm755 /usr/share/doc/python-3.8.1/html 

    tar --strip-components=1  \
        --no-same-owner       \
        --no-same-permissions \
        -C /usr/share/doc/python-3.8.1/html \
        -xvf ../python-3.8.1-docs-html.tar.bz2
	
    rm -rvf $TG
    cd $SRC
}

function install_ninja ()
{
    cd $SRC
    local TG=$(extract ninja-1.10.0.tar.gz)
    cd $TG

    python3 configure.py --bootstrap
    install -vm755 ninja /usr/bin/
    install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
    install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

    rm -rvf $TG
    cd $SRC
}

function install_meson ()
{
    cd $SRC
    local TG=$(extract meson-0.53.1.tar.gz)
    cd $TG

    python3 setup.py build
    python3 setup.py install --root=dest
    cp -rv dest/* /

    rm -rvf $TG
    cd $SRC
}

function install_coreutils ()
{
    cd $SRC
    local TG=$(extract coreutils-8.31.tar.xz)
    cd $TG

    patch -Np1 -i ../coreutils-8.31-i18n-1.patch
    sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk
    autoreconf -fiv
    FORCE_UNSAFE_CONFIGURE=1 ./configure \
                --prefix=/usr            \
                --enable-no-install-program=kill,uptime
    make
    make NON_ROOT_USERNAME=nobody check-root
    local ERR=$?
    if [ $ERR -eq 0 ]; then
    	echo "dummy:x:1000:nobody" >> /etc/group
    	chown -Rv nobody . 
    	su nobody -s /bin/bash \
              -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
    	ERR=$?
    	sed -i '/dummy/d' /etc/group
    fi			

    make install 
    mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
    mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
    mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
    mv -v /usr/bin/chroot /usr/sbin
    mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
    sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8
    mv -v /usr/bin/{head,nice,sleep,touch} /bin

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_check ()
{
    cd $SRC
    local TG=$(extract check-0.14.0.tar.gz)
    cd $TG

    ./configure --prefix=/usr
    make
    make check
    local ERR=$?
    [ $ERR -ne 0 ] && echo "[ERROR]: building $TG failed"
    make docdir=/usr/share/doc/check-0.14.0 install &&
    sed -i '1 s/tools/usr/' /usr/bin/checkmk

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_diffutils ()
{
    cd $SRC
    local TG=$(extract diffutils-3.7.tar.xz)
    cd $TG

    make_generic --prefix=/usr
    local ERR=$?

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_gawk ()
{
    cd $SRC
    local TG=$(extract gawk-5.0.1.tar.xz)
    cd $TG

    sed -i 's/extras//' Makefile.in
    make_generic --prefix=/usr
    local ERR=$?
    mkdir -v /usr/share/doc/gawk-5.0.1
    cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.0.1

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_findutils ()
{
    cd $SRC
    local TG=$(extract findutils-4.7.0.tar.xz)
    cd $TG

    make_generic --prefix=/usr --localstatedir=/var/lib/locate
    local ERR=$?
    mv -v /usr/bin/find /bin
    sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_groff ()
{
    cd $SRC
    local TG=$(extract groff-1.22.4.tar.gz )
    cd $TG

    PAGE=A4 ./configure --prefix=/usr
    make -j1
    make install

    rm -rvf $TG
    cd $SRC
}

function install_grub ()
{
    cd $SRC
    local TG=$(extract grub-2.04.tar.xz)
    cd $TG

    ./configure --prefix=/usr          \
                --sbindir=/sbin        \
                --sysconfdir=/etc      \
                --disable-efiemu       \
                --disable-werror

    make
    make install
    mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
			
    rm -rvf $TG
    cd $SRC
}

function install_less ()
{
    cd $SRC
    local TG=$(extract less-551.tar.gz)
    cd $TG

    ./configure --prefix=/usr --sysconfdir=/etc
    make
    make install

    rm -rvf $TG
    cd $SRC
}

function install_gzip ()
{
    cd $SRC
    local TG=$(extract gzip-1.10.tar.xz)
    cd $TG

    make_generic --prefix=/usr
    local ERR=$?
    mv -v /usr/bin/gzip /bin

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_zstd ()
{
    cd $SRC
    local TG=$(extract zstd-1.4.4.tar.gz)
    cd $TG

    make
    make prefix=/usr install
    rm -v /usr/lib/libzstd.a
    mv -v /usr/lib/libzstd.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libzstd.so) /usr/lib/libzstd.so

    rm -rvf $TG
    cd $SRC
}

function install_iproute2 ()
{
    cd $SRC
    local TG=$(extract iproute2-5.5.0.tar.xz )
    cd $TG

    sed -i /ARPD/d Makefile
    rm -fv man/man8/arpd.8
    sed -i 's/.m_ipt.o//' tc/Makefile
    make DOCDIR=/usr/share/doc/iproute2-5.5.0 install

    rm -rvf $TG
    cd $SRC
}

function install_kbd ()
{
    cd $SRC
    local TG=$(extract kbd-2.2.0.tar.xz )
    cd $TG

    patch -Np1 -i ../kbd-2.2.0-backspace-1.patch
    sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
    sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
    PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock
    make
    make check
    local ERR=$?
    [ $ERR -ne 0 ] && echo "[ERROR]: build failed"
    make install
    mkdir -v       /usr/share/doc/kbd-2.2.0
    cp -R -v docs/doc/* /usr/share/doc/kbd-2.2.0

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_libpipeline ()
{
    cd $SRC
    local TG=$(extract libpipeline-1.5.2.tar.gz )
    cd $TG

    make_generic --prefix=/usr
    local ERR=$?

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_make ()
{
    cd $SRC
    local TG=$(extract make-4.3.tar.gz )
    cd $TG

    ./configure --prefix=/usr
    make
    make PERL5LIB=$PWD/tests/ check
    local ERR=$?
    [ $ERR -ne 0 ] && echo "[ERROR]: build failed"
    make install

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_patch ()
{
    cd $SRC
    local TG=$(extract patch-2.7.6.tar.xz )
    cd $TG

    make_generic --prefix=/usr 
    local ERR=$?

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_man-db ()
{
    cd $SRC
    local TG=$(extract man-db-2.9.0.tar.xz )
    cd $TG

    make_generic --prefix=/usr                        \
                --docdir=/usr/share/doc/man-db-2.9.0 \
                --sysconfdir=/etc                    \
                --disable-setuid                     \
                --enable-cache-owner=bin             \
                --with-browser=/usr/bin/lynx         \
                --with-vgrind=/usr/bin/vgrind        \
                --with-grap=/usr/bin/grap            \
                --with-systemdtmpfilesdir=           \
                --with-systemdsystemunitdir= 
    local ERR=$?

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_tar ()
{
    cd $SRC
    local TG=$(extract tar-1.32.tar.xz )
    cd $TG

    FORCE_UNSAFE_CONFIGURE=1  \
    ./configure --prefix=/usr \
                --bindir=/bin
    make
    make check			
    local ERR=$?
    [ $ERR -ne 0 ] && echo "[ERROR]: build failed"
    make install
    make -C doc install-html docdir=/usr/share/doc/tar-1.32

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_texinfo ()
{
    cd $SRC
    local TG=$(extract texinfo-6.7.tar.xz )
    cd $TG

    make_generic --prefix=/usr --disable-static
    local ERR=$?
    make TEXMF=/usr/share/texmf install-tex
    pushd /usr/share/info
    rm -v dir
    for f in *
      do install-info $f dir 2>/dev/null
    done
    popd

    rm -rvf $TG
    cd $SRC
    return $ERR
}


function install_vim ()
{
    cd $SRC
    local TG=$(extract vim-8.2.0190.tar.gz )
    cd $TG

    echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
    ./configure --prefix=/usr
    make
    make install
    ln -sv vim /usr/bin/vi
    for L in  /usr/share/man/{,*/}man1/vim.1; do
        ln -sv vim.1 $(dirname $L)/vi.1
    done
    ln -sv ../vim/vim82/doc /usr/share/doc/vim-8.2.0190

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1 

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF

    rm -rvf $TG
    cd $SRC
}

function install_procps-ng ()
{
    cd $SRC
    local TG=$(extract procps-ng-3.3.15.tar.xz )
    cd $TG

    ./configure --prefix=/usr                            \
                --exec-prefix=                           \
                --libdir=/usr/lib                        \
                --docdir=/usr/share/doc/procps-ng-3.3.15 \
                --disable-static                         \
                --disable-kill
    
    make
    sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
    sed -i '/set tty/d' testsuite/pkill.test/pkill.exp
    rm testsuite/pgrep.test/pgrep.exp
    make check
    local ERR=$?
    make install
    mv -v /usr/lib/libprocps.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_util-linux ()
{
    cd $SRC
    local TG=$(extract util-linux-2.35.1.tar.xz )
    cd $TG

    mkdir -pv /var/lib/hwclock
    ./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
                --docdir=/usr/share/doc/util-linux-2.35.1 \
                --disable-chfn-chsh  \
                --disable-login      \
                --disable-nologin    \
                --disable-su         \
                --disable-setpriv    \
                --disable-runuser    \
                --disable-pylibmount \
                --disable-static     \
                --without-python     \
                --without-systemd    \
                --without-systemdsystemunitdir
    make
    make install

    rm -rvf $TG
    cd $SRC
}

function install_e2fsprogs ()
{
    cd $SRC
    local TG=$(extract e2fsprogs-1.45.5.tar.gz )
    cd $TG

    mkdir -v build
    cd       build
    ../configure --prefix=/usr           \
                 --bindir=/bin           \
                 --with-root-prefix=""   \
                 --enable-elf-shlibs     \
                 --disable-libblkid      \
                 --disable-libuuid       \
                 --disable-uuidd         \
                 --disable-fsck
    make
    make check
    local ERR=$?
    [ $ERR -ne 0 ] && echo "[ERROR]: build failed"
    make install			 

    chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
    gunzip -v /usr/share/info/libext2fs.info.gz
    install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
    makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
    install -v -m644 doc/com_err.info /usr/share/info
    install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

    rm -rvf $TG
    cd $SRC
    return $ERR
}

function install_sysklogd ()
{
    cd $SRC
    local TG=$(extract sysklogd-1.5.1.tar.gz )
    cd $TG

    sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
    sed -i 's/union wait/int/' syslogd.c

    make
    make BINDIR=/sbin install

cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF

    rm -rvf $TG
    cd $SRC
}

function install_sysvinit ()
{
    cd $SRC
    local TG=$(extract sysvinit-2.96.tar.xz )
    cd $TG

    patch -Np1 -i ../sysvinit-2.96-consolidated-1.patch
    make
    make install

    rm -rvf $TG
    cd $SRC
    return $ERR
}


function install_eudev ()
{
    cd $SRC
    local TG=$(extract eudev-3.2.9.tar.gz )
    cd $TG

    mkdir -pv /lib/udev/rules.d
    mkdir -pv /etc/udev/rules.d

    make_generic --prefix=/usr           \
                --bindir=/sbin          \
                --sbindir=/sbin         \
                --libdir=/usr/lib       \
                --sysconfdir=/etc       \
                --libexecdir=/lib       \
                --with-rootprefix=      \
                --with-rootlibdir=/lib  \
                --enable-manpages       \
                --disable-static
    local ERR=$?
    tar -xvf ../udev-lfs-20171102.tar.xz
    make -f udev-lfs-20171102/Makefile.lfs install
    udevadm hwdb --update

    rm -rvf $TG
    cd $SRC
    return $ERR
}

#------------------------------------------------

source $WRK/vfs_scripts/utils.sh
#--------------- main ---------------------------
s_start $0
ST=$?

run_cmd install_libtool
run_cmd install_gdbm
run_cmd install_gperf
run_cmd install_expat
run_cmd install_inetutils
run_cmd install_perl
run_cmd install_xml-parser
run_cmd install_intltools
run_cmd install_autconf
run_cmd install_automake
run_cmd install_kmod
run_cmd install_gettext
run_cmd install_elfutils
run_cmd install_libffi

run_cmd install_openssl
run_cmd install_python
run_cmd install_ninja
run_cmd install_meson
run_cmd install_coreutils
run_cmd install_check
run_cmd install_diffutils
run_cmd install_gawk
run_cmd install_findutils
run_cmd install_groff
run_cmd install_grub
run_cmd install_less
run_cmd install_gzip
run_cmd install_zstd
run_cmd install_iproute2

run_cmd install_kbd
run_cmd install_libpipeline
run_cmd install_make
run_cmd install_patch
run_cmd install_man-db
run_cmd install_tar
run_cmd install_texinfo
run_cmd install_vim
run_cmd install_procps-ng
run_cmd install_util-linux
run_cmd install_e2fsprogs
run_cmd install_sysklogd
run_cmd install_sysvinit
run_cmd install_eudev

s_end $0
ED=$?
s_duration $0 $ST $ED
