#!/bin/bash
function install_tool () 
{
  echo "installing $1...."
  apt-get install -y $1
}

function check_tool ()
{
  echo -n "checking $1 "
  $1 --version &> /dev/null
  if [ $? -ne 0 ]; then
    echo ".......No"
    install_tool $1
  else
    echo " ........OK"
  fi
}

function check_build_essentials ()
{
  gcc --version &> /dev/null
  if [ $? -ne 0 ]; then
    apt-get install -y build-essential
  fi  
}

function check_coreutils ()
{
  chown --version &> /dev/null
  if [ $? -ne 0 ]; then
    apt-get install -y coreutils
  fi  
}

function check_diffutils ()
{
  diff --version &> /dev/null
  if [ $? -ne 0 ]; then
    apt-get install -y diffutils
  fi  
}

function check_findutils ()
{
  find --version &> /dev/null
  if [ $? -ne 0 ]; then
    apt-get install -y findutils
  fi  
}

function check_makeinfo ()
{
  makeinfo --version &> /dev/null
  if [ $? -ne 0 ]; then
    apt-get install -y texinfo
  fi  
}

#-----------------------------------
echo "---------------- $0 ---------------------"
apt-get update

export LC_ALL=C
check_tool "bash"
bash --version | head -n1 | cut -d" " -f2-4
MYSH=$(readlink -f /bin/sh)
echo "/bin/sh -> $MYSH"
echo $MYSH | grep -q bash || echo "[ERROR]: /bin/sh does not point to bash" && \
echo "fix it" && ln -v -s -f /usr/bin/bash sh
unset MYSH

check_build_essentials
echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-

check_tool "bison"
bison --version | head -n1

if [ -h /usr/bin/yacc ]; then
  echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
elif [ -x /usr/bin/yacc ]; then
  echo yacc is `/usr/bin/yacc --version | head -n1`
else
  echo "[ERROR]: yacc not found" 
fi

check_tool "bzip2"
bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-

check_coreutils
echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2

check_diffutils
diff --version | head -n1

check_findutils
find --version | head -n1

check_tool gawk
gawk --version | head -n1
if [ -h /usr/bin/awk ]; then
  echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
elif [ -x /usr/bin/awk ]; then
  echo awk is `/usr/bin/awk --version | head -n1`
else 
  echo "[ERROR]: awk not found" 
fi

gcc --version | head -n1
g++ --version | head -n1
ldd --version | head -n1 | cut -d" " -f2-  # glibc version

check_tool "grep"
grep --version | head -n1

check_tool "gzip"
gzip --version | head -n1

cat /proc/version

check_tool "m4"
m4 --version | head -n1

make --version | head -n1

check_tool "patch"
patch --version | head -n1

check_tool "perl"
echo Perl `perl -V:version`

check_tool "python3"
python3 --version

check_tool "sed"
sed --version | head -n1

check_tool "tar"
tar --version | head -n1

check_makeinfo
makeinfo --version | head -n1  # texinfo version

check_tool "xz"
xz --version | head -n1

check_tool "wget"
wget --version | head -n1

ERROR=0
echo 'int main(){}' > dummy.c
g++ -o dummy dummy.c
if [ -x dummy ];  then 
  echo "g++ compilation OK";
else 
  echo "[ERROR]: g++ compilation failed"
  ERROR=2
fi
rm -f dummy.c dummy

exit $ERROR