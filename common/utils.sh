
function run_cmd ()
{
  echo ".......... $1 ........"
  eval $1
  return $?
}

function s_start ()
{
    local START_TIME=$(date +"%s")
    echo "---------- START: $1  [ $(date -d@$START_TIME -u +%H:%M:%S) ] -----------"
    return $START_TIME
}

function s_end ()
{
    local END_TIME=$(date +"%s")
    echo "---------END: $1  [ $(date -d@$END_TIME -u +%H:%M:%S) ] --------------"
    return $END_TIME
}

function s_duration ()
{
    local DURATION=$(expr $3 - $2)
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
    xz) echo  xJf;;
    gz) echo  xzf;;
    bz2) echo xjf;;
    *) echo "";;
    esac
}

function extract ()
{
    local FILE="$1"
    local DIR="$(get_tool $FILE)"
    local EXT="$(get_ext $FILE)"
    local OPT="$(get_opt $EXT)"
    tar $OPT "$FILE"
    if [ -d "$DIR" ]; then
        echo $DIR
        return 0
    else
        echo "NONE"
        return 1
    fi
}

function build_generic
{
    local TG="$(get_tool $1)"
    if [ ! -d "$TG" ]; then
        extract $1
    fi 
     
    cd $TG
    ./configure --prefix=/tools "$2"
    make
    make check
    ERR=$?
    make install

    rm -rf $TG
    cd $SRC
    return $ERR
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
