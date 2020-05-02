#!/bin/bash
function _help ()
{
    echo "USAGE: $( basename $0 ) -s|--sources <src_dir|file>"
}

function _generate_with_template ()
{
	CZ="$1"
	C=$(get_tool $CZ)
	SK="$DEST/build_$C.sh"
	echo "generating $SK"
	cp $DEST/build_script_template $SK
	chmod +x $SK

	sed -i s/@_COMPONENT_/$1/g $SK
}

function _generate ()
{
	CZ="$1"
	C=$(get_tool $CZ)
	SK="$DEST/build_$C.sh"
	echo "generating $SK"
	touch $SK
	chmod +x $SK

	echo	"#!/bin/bash" > $SK
	echo	"" >> $SK
	echo	"ERROR=0" >> $SK
	echo	"" >> $SK
	echo	"function _build () " >> $SK
	echo	"{" >> $SK
	echo -e "\tlocal ERR=0" >> $SK
	echo -e	"\t./configure --prefix=/usr" >> $SK
	echo -e	"\tmake" >> $SK
	echo -e	'\tif [ "$1" == "--test" ]; then' >> $SK
	echo -e	"\t\tmake check" >> $SK
	echo -e	'\t\tERR=$?' >> $SK
	echo -e	"\tfi" >> $SK
	echo -e	'\t[ $ERR -eq 0 ] && make install || echo "[ERROR]: build failed"' >> $SK
	echo -e	'\treturn $ERR' >> $SK
	echo 	"}" >> $SK
	echo	"" >> $SK
	echo	"source ../common/utils.sh" >> $SK
	echo	"#----------------------------------------" >> $SK
	echo	"" >> $SK
    echo	'cd $SRC' >> $SK
	echo	'TG=$(extract ' " $CZ)" >> $SK
	echo 	'cd $TG' >> $SK
	echo	"" >> $SK
	echo	"_build" >> $SK
	echo	'ERROR=$?' >> $SK
	echo	"" >> $SK
	echo	'cd $SRC' >> $SK
	echo	'rm -v -rf $TG' >> $SK
	echo	'exit $ERROR' >> $SK
}

source common/utils.sh
#----------------------------------------------------------
echo "================ START ================"

[ $# -ne 2 ] && _help && exit 1

SC=
SRC_DIR=
SRCS=
DEST="$(pwd)/components"

while [ "$1" ]; do
    case "$1" in
    -s|--sources)
		shift 
		SC="$1" 
		;;
    *)   
		_help
		exit 1
		;;
    esac
    shift
done

[ ! -e "$SC" ] && echo "[ERROR]: $SC file or directory not found" && exit 1
[ ! -d "$DEST" ] && \
	echo "[ERROR]: destination directory does not exist yet. Create one call 'components'" && \
	exit 1

if [ -f "$SC" ]; then
	SRCS="$(basename $SC)"
else
	SRCS="$(ls -1 $SC)"
fi


for CMPZ in $SRCS; do
	if [[ "$CMPZ" == *".tar."* ]]; then
		echo "-----"
		echo $CMPZ	
		_generate_with_template $CMPZ
	fi
done

echo "===================================="
ls -al $DEST