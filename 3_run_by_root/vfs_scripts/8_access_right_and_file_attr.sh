SRC="/sources"

#------------------------------------------------

function install_attr ()
{
    cd $SRC
    local TG=$(extract attr-2.4.48.tar.gz )
    cd $TG

    ./configure --prefix=/usr     \
                --bindir=/bin     \
                --disable-static  \
                --sysconfdir=/etc \
                --docdir=/usr/share/doc/attr-2.4.48
    make
    make check
    make install
    mv -v /usr/lib/libattr.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so

    cd $SRC
    rm -rf $TG
}

function install_acl ()
{
    cd $SRC
    local TG=$(extract acl-2.2.53.tar.gz )
    cd $TG

    ./configure --prefix=/usr         \
                --bindir=/bin         \
                --disable-static      \
                --libexecdir=/usr/lib \
                --docdir=/usr/share/doc/acl-2.2.53

    make
    make install
    mv -v /usr/lib/libacl.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so

    cd $SRC
    rm -rf $TG
}

function install_shadow ()
{
    cd $SRC
    local TG=$(extract shadow-4.8.1.tar.xz )
    cd $TG

    sed -i 's/groups$(EXEEXT) //' src/Makefile.in
    find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
    find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
    find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

    sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
           -e 's@/var/spool/mail@/var/mail@' etc/login.defs
    sed -i 's/1000/999/' etc/useradd
    ./configure --sysconfdir=/etc --with-group-name-max-length=32
    make
    make install
    pwconv
    grpconv
    ( echo edge; echo edge ) | passwd root

    cd $SRC
    rm -rf $TG
}

#------------------------------------------------

source /vfs_scripts/utils.sh
#--------------- main ---------------------------
s_start $0
ST=$?

run_cmd install_attr
run_cmd install_acl
run_cmd install_shadow

s_end $0
ED=$?
s_duration $0 $ST $ED
exit $ERROR