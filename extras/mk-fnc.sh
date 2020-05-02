#!/bin/bash

CD=$(realpath $0)
CD=$(dirname $CD)

#-----------------------------------------------------
function _help ()
{
    echo "USAGE: $( basename $0 ) -s|--sources <src_dir|file> <src_dir|file>..."
}

function _overwrite_file ()
{
	if [ -e "$1" ]; then
		local T="$1"
		echo -n "File $1 exists. Overwrite it ? [Y/N]: "
		while read QT; do 
			if [ "$QT" = "N" -o "$QT" = "n" ]; then
		  		echo "$2 skipped..."
				return 0
			elif [ "$QT" = "Y" -o "$QT" = "y"  ]; then
				return 1
			else
				echo -n "Not understood. [Y/N]: "
			fi
		done
	else
		return 1
	fi
}

function _generate_with_template ()
{
	CZ="$1"
	C=$(get_tool $CZ)
	SK="$DEST/build_$C.sh"

	_overwrite_file $SK $CZ
	[ $? = 0 ] && return 1

	echo "generating $SK"
	cp $CD/build_script_template $SK
	chmod +x $SK	
	sed -i s/"@_COMPONENT_"/$1/g $SK
}


source $CD/../common/utils.sh
#----------------------------------------------------------
echo "================ START ================"
[ $# -lt 2 ] && _help && exit 1

SC=
SRCS=
DEST="components"

case "$1" in
-s|--sources)
	shift 
	;;
*)   
	_help
	exit 1
	;;
esac

for SC in "$@"; do
	[ ! -e "$SC" ] && echo "[ERROR]: $SC file or directory not found" && exit 1
	if [ -f "$SC" ]; then
		SRCS="$SRCS $(basename $SC)"
	else
		SRCS="$SRCS $(ls -1 $SC)"
	fi
done

[ ! -d "$DEST" ] && mkdir -v -p $DEST

for CMPZ in $SRCS; do
	if [[ "$CMPZ" == *".tar."* ]]; then
		echo "-----"
		echo $CMPZ	
		_generate_with_template $CMPZ
	fi
done

echo "===================================="
ls -al $DEST