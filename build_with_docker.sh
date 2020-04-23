#!/bin/bash
BUILD=
RUN=
CN="lfslab"
TAG="v1.0"
VOL="$(pwd)/lfs_volume"

function _help ()
{
    echo "USAGE: $( basename $0 ) -a|--all|-b|--build|-r|--run <cmd>"
}

function _build_image ()
{
    docker rmi $CN:$TAG 2> /dev/null       
    docker build -t $CN:$TAG .
    return $?
}

function _run_container ()
{
    [ -d "$VOL.backup" ] && rm -rvf $VOL.backup
    [ -d "$VOL" ] && mv -v $VOL $VOL.backup
    rm -vrf $VOL &> /dev/null
    mkdir  $VOL
    docker run -v $VOL:/lfs/results --name $CN  $CN:$TAG "$@"
    return $?
}

#----------------------------------------------------------
docker rm -f $(docker ps -aq) 2> /dev/null
[ $# -eq 0 ] && _help && exit 1
echo "================ START ================"
CD=$(realpath $0)
CD=$(dirname $CD)
cd $CD

while [ "$1" ]; do
    case $1 in
    -b|--build)
        _build_image
        exit $?
        ;;
    -r|--run)
        shift
        _run_container "$@"
        exit $?
        ;;
    -a|--all)
        shift
        _build_image
        ERR=$?
        if [ $ERR -eq 0 ]; then
            _run_container "$@"
            ERR=$?
        else
            echo "[ERROR]: building image failed"
        fi
        exit $ERR
        ;;
    *)
        _help
        exit 1
        ;;
    esac
    shift
done

echo "================ END ================"
