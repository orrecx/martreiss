SRC="/sources"

#------------------------------------------------

function install_gmp ()
{
    cd $SRC
    local TG=$(extract gmp-6.2.0.tar.xz )
    cd $TG

    cp -v configfsf.guess config.guess
    cp -v configfsf.sub   config.sub
    ./configure --prefix=/usr    \
                --enable-cxx     \
                --disable-static \
                --docdir=/usr/share/doc/gmp-6.2.0
    make
    make html
    make check 2>&1 | tee gmp-check-log
    awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
    make install
    make install-html

    cd $SRC
    rm -rf $TG
}

function install_mpfr ()
{
    cd $SRC
    local TG=$(extract mpfr-4.0.2.tar.xz )
    cd $TG

    ./configure --prefix=/usr        \
                --disable-static     \
                --enable-thread-safe \
                --docdir=/usr/share/doc/mpfr-4.0.2

    make
    make html
    make check
    ERR=$?
    make install
    make install-html
    cd $SRC
    rm -rf $TG
    return $ERR
}

function install_mpc ()
{
    cd $SRC
    local TG=$(extract mpc-1.1.0.tar.gz )
    cd $TG

    ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/mpc-1.1.0
    make
    make html
    make check
    ERR=$?
    make install
    make install-html

    cd $SRC
    rm -rf $TG
    return $ERR
}

#------------------------------------------------

source /vfs_scripts/utils.sh
#--------------- main ---------------------------
s_start $0
ST=$?

run_cmd install_gmp
run_cmd install_mpfr
run_cmd install_mpc

s_end $0
ED=$?
s_duration $0 $ST $ED
