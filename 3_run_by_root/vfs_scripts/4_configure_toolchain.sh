#backup current ld
source /vfs_scripts/utils.sh

s_start $0

echo "-------------- $0 -----------------"
mv -v /tools/bin/{ld,ld-old}
mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
cp -v /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld

#change gcc spec
gcc -dumpspecs | sed -e 's@/tools@@g'                   \
    -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
    -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
    `dirname $(gcc --print-libgcc-file-name)`/specs

#test if it works
echo 'int main(){}' > dummy.c
echo "compile dummy.c"
cc dummy.c -v -Wl,--verbose &> dummy.log
[ $? -ne 0 ] && echo "[ERROR]: failed to compile dummy.c" && cat dummy.log
readelf -l a.out | grep ': /lib'
ERROR=$?

if [ $ERROR -ne 0 ]; then
    echo "[ERROR]: configuration of toolchain failed"
else
    set -v
    grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
    grep -B1 '^ /usr/include' dummy.log
    grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
    grep "/lib.*/libc.so.6 " dummy.log
    grep found dummy.log
    set +v
fi
rm -v dummy.c a.out dummy.log

s_end $0
exit $ERROR
