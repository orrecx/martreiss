#!/bin/bash
cd "$( dirname $(realpath $0))"

BUILD=
RUN=
VOL="$(pwd)/lfs_volume"

CN="matrissys"
BASIS_IMG="build-env-basic"
IMG_TAG="v1.1"

function _help ()
{
    echo "USAGE: $( basename $0 ) -a|--all|-b|--build|-r|--run <cmd>"
}

function _build_basic_image ()
{
    local ERR=0
    docker images --format "{{.Repository}}:{{.Tag}}" | grep "$BASIS_IMG:$IMG_TAG"
    if [ $? -ne 0 ]; then
        echo "-------------- building image $BASIS_IMG:$IMG_TAG ------------- "
        pushd prebuild
        docker build -t $BASIS_IMG:$IMG_TAG -f Dockerfile_basicImage .
        ERR=$?
        [ $ERR -ne 0 ] && echo "building $BASIS_IMG:$IMG_TAG failed"
        popd    
    fi 
    return $ERR
}

function _build_image ()
{
    echo "-------------- building image $CN:$IMG_TAG ------------- "
    local ERR=0
    _build_basic_image
    ERR=$?
    [ $ERR -ne 0 ] && return $ERR 
    docker rmi $CN:$IMG_TAG 2> /dev/null       
    docker build --build-arg baseimage="$BASIS_IMG:$IMG_TAG" -t $CN:$IMG_TAG .
    return 0
}

function _run_container ()
{
    docker rm -f $CN &> /dev/null
    [ -d "$VOL.backup" ] && rm -rvf $VOL.backup
    [ -d "$VOL" ] && mv -v $VOL $VOL.backup
    mkdir  -v $VOL
    docker run -v $VOL:/lfs/results --name $CN  $CN:$IMG_TAG "$@"
    return $?
}

#----------------------------------------------------------
echo "================ START ================"
[ $# -eq 0 ] && _help && exit 1

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
