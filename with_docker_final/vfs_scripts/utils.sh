
function run_cmd ()
{
  echo ".......... $1 ........"
  eval $1
  return $?
}

function s_start ()
{
    local START_TIME=$(date +"%s")
    echo "---------- START: $1 -----------"
    echo "START: $(date -d@$START_TIME -u +%H:%M:%S)"
    echo "-----------------------"
    return $START_TIME
}

function s_end ()
{
    local END_TIME=$(date +"%s")
    echo "---------END: $0 --------------"
    echo "END: $(date -d@$END_TIME -u +%H:%M:%S)"
    echo "-----------------------"
    return $END_TIME
}

function s_duration ()
{
    local DURATION=$(expr $2 - $3)
    echo "$0 build time: $(date -d@$DURATION -u +%H:%M:%S) "
    return $DURATION
}

function tokenize ()
{
    K=$(echo $1 | awk '{split($0, arr, ".tar."); print arr[1]; print arr[2]}')
    echo $K
}

function get_tool ()
{
    echo $1 | awk '{split($0, arr, ".tar."); print arr[1]}'    
}

function get_ext ()
{
    echo $1 | awk '{split($0, arr, ".tar."); print arr[2]}'
}

function get_opt ()
{
    case "$1" in
    xz) echo  xJf ;;
    gz) echo  xzf ;;
    bz2) echo xjf ;;
    *) echo "-" ;;
    esac
}

function extract ()
{
    local FILE="$1"
    local DIR="$(get_tool $FILE)"
    local EXT="$(get_ext $FILE)"
    local OPT="$(get_opt $EXT)"
    echo "uncompressing $FILE"
    tar $OPT "$FILE"
    if [ -d "$DIR" ]; then
        echo DIR
        return 0
    else
        return 1
    fi
}

function build_generic
{
    local T=$1
    local LN=$(echo ${#T})
    local N=$(expr $LN - 7)
    local TG="$(echo ${T:0:$N})"
    local EXT="$(echo ${T:$(expr $N + 5) })"
    local TAR_OP=$( [ $EXT = "xz" ] && echo "xvJf" || echo "xvzf" )
    
    [ ! -d "$TG" ] && tar $TAR_OP "$TG.tar.$EXT"
    cd $TG
    ./configure --prefix=/tools "$2"
    make
    make check
    make install

    cd $SRC
    rm -rf $TG
}

function make_generic ()
{
    ./configure "$@"
    make
    make check
    $ERR=$?
    [ $ERR -ne 0 ] && echo "[ERROR]: Build failed"			
    make install
    return $ERR
}
