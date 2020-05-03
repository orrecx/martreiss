#!/bin/bash
cd "$( dirname $(realpath $0))"

BUILD=
RUN=
CN="matrissys"
TAG="v1.0"
VOL="$(pwd)/lfs_volume"

BASIS_IMG="build-env-basic"
BASIS_IMG_TAG="v1.0"

function _help ()
{
    echo "USAGE: $( basename $0 ) -a|--all|-b|--build|-r|--run <cmd>"
}

function _build_basic_image ()
{
    local ERR=0
    docker images --format "{{.Repository}}:{{.Tag}}" | grep "$BASIS_IMG:$BASIS_IMG_TAG"
    if [ $? -ne 0 ]; then
        pushd prebuild
        docker build -t $BASIS_IMG:$BASIS_IMG_TAG -f Dockerfile_basicImage .
        ERR=$?
        [ $ERR -ne 0 ] && echo "building $BASIS_IMG:$BASIS_IMG_TAG failed"
        popd    
    fi 
    return $ERR
}

function _build_image ()
{
    local ERR=0
    _build_basic_image
    ERR=$?
    [ $ERR -ne 0 ] && return $ERR 
    docker rmi $CN:$TAG 2> /dev/null       
    docker build --build-arg baseimage="$BASIS_IMG:$BASIS_IMG_TAG" -t $CN:$TAG .
    return 0
}

function _run_container ()
{
    docker rm -f $CN &> /dev/null
    [ -d "$VOL.backup" ] && rm -rvf $VOL.backup
    [ -d "$VOL" ] && mv -v $VOL $VOL.backup
    mkdir  -v $VOL
    docker run -v $VOL:/lfs/results --name $CN  $CN:$TAG "$@"
    return $?
}

#----------------------------------------------------------
[ $# -eq 0 ] && _help && exit 1
echo "================ START ================"
CD=$(realpath $0)
CD=$(dirname $CD)
cd $CD

while [ "x$1" != "x" ]; do
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
