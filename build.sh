#!/bin/bash
function _help ()
{
    echo "USAGE: $( basename $0 ) -a|--all|-b|--build|-r|--run <cmd>"
}

#----------------------------------------------------------
echo "================ START ================"
CD=$(realpath $0)
CD=$(dirname $CD)
cd $CD
_help
echo "================ END ================"
