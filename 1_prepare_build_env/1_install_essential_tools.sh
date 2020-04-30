#!/bin/bash
# Simple script to list version numbers of critical development tools
function install_all_needed_tools ()
{
  apt-get update
  echo "installing needed tools"
  apt-get install -y bash grep gzip binutils-common bison bzip2 coreutils diffutils findutils gawk \
  m4 patch perl python3 sed tar texinfo xz build-essentials
}

function check_tools_version ()
{
  bash --version | head -n1 | cut -d" " -f2-4
  MYSH=$(readlink -f /bin/sh)
  echo "/bin/sh -> $MYSH"
  echo $MYSH | grep -q bash || echo "[ERROR]: /bin/sh does not point to bash"
  unset MYSH

  echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-
  bison --version | head -n1

  if [ -h /usr/bin/yacc ]; then
    echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
  elif [ -x /usr/bin/yacc ]; then
    echo yacc is `/usr/bin/yacc --version | head -n1`
  else
    echo "[ERROR]: yacc not found" 
  fi

  bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-
  echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
  diff --version | head -n1
  find --version | head -n1
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
  grep --version | head -n1
  gzip --version | head -n1
  cat /proc/version
  m4 --version | head -n1
  make --version | head -n1
  patch --version | head -n1
  echo Perl `perl -V:version`
  python3 --version
  sed --version | head -n1
  tar --version | head -n1
  makeinfo --version | head -n1  # texinfo version
  xz --version | head -n1
}

function check_c_compiler ()
{
  local ERR=0
  echo 'int main(){}' > dummy.c
  g++ -o dummy dummy.c
  if [ -x dummy ]; then 
    echo "g++ compilation OK"
  else echo "[ERROR]: g++ compilation failed"
    ERR=1
  fi
  rm -f dummy.c dummy &> /dev/null
  return $ERR
}

echo "---------------- $0 ---------------------"
export LC_ALL=C

install_all_needed_tools
check_tools_version
check_c_compiler

exit $?
