#!/bin/bash

function run_cmd()
{
    echo ""
    echo "########### run $1 #############"
    local S_TIME=$(date +"%s")
    echo "$(date)"
    eval "$1"
    local ERR=$?
    local E_TIME=$(date +"%s")
    echo "$(date)"
    DUR=$(expr $E_TIME - $S_TIME)
    echo "##### DURATION of $1: $(date -d@$DUR -u +%H:%M:%S) ####"
    return $ERR
} 
