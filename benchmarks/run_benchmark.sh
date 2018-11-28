#!/usr/bin/env bash

timestamp ()
{
    echo $(date +%s)"000" 
}

run_benchmark ()
{
    MAX_CORES=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l) 
    CMD=$1
    START=$(timestamp)
    $CMD
    END=$(timestamp)
    echo "http://192.168.42.60:3000/d/VLu4G_aik/power-tools?orgId=1&from=$START&to=$END"
}
