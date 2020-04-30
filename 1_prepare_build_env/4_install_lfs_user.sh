#!/bin/bash
echo "---------------- $0 ---------------------"
US="lfs"
HM="/home/$US"

[ ! -d "$LFS" ] && echo "[ERROR]: Environment variable LFS is not set yet or directory $LFS does not exist." && exit 1
[ $(id --user) -ne 0 ] && echo "[ERROR]: only root is allowed to run this script. use sudo" && exit 2

groupadd $US
useradd -s /bin/bash -g $US -m -k /dev/null $US
(
    echo "edge"
    echo "edge"
) | passwd $US

chown -v -R $US:$US $LFS

cat > $HM/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$' /bin/bash
EOF

cat > $HM/.bashrc << "EOF"
set +h
umask 022
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LC_ALL LFS_TGT PATH
alias ll="ls -al"
EOF
echo "LFS=$LFS" >> $HM/.bashrc
echo "export LFS" >> $HM/.bashrc

chown -v -R $US:$US $HM