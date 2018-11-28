#!/usr/bin/env bash
source ./run_benchmark.sh

disk_load ()
{
    DISK=$1
    COUNTS=$2
    PATH=/dev/$DISK/benchmarkfile
    dd if=/dev/zero of=$PATH bs=250M count=$COUNTS oflag=direct
}

run ()
{
    COUNTS=16
    DISKS=$(lsblk -d | grep disk | awk '{ print $1 }')
    #disk_load ${DISKS[0]} $COUNTS
    dd if=/dev/zero of=/tmp/testfile bs=250M count=$COUNTS oflag=direct
}

run_benchmark run "disk"
