source $WRK/vfs_scripts/utils.sh

s_start $0
S=$?

rm -f /usr/lib/lib{bfd,opcodes}.a
rm -f /usr/lib/libbz2.a
rm -f /usr/lib/lib{com_err,e2p,ext2fs,ss}.a
rm -f /usr/lib/libltdl.a
rm -f /usr/lib/libfl.a
rm -f /usr/lib/libz.a
find /usr/lib /usr/libexec -name \*.la -delete

#rm -rvf /tools

s_end $0
E=$?
s_duration $0 $S $E

