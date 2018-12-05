#!/usr/bin/env bash
source ./run_benchmark.sh

disk_load ()
{
    COUNTS=$1
    TEST_FILE="$(pwd)/benchmark_file.txt"
    touch $TEST_FILE
    dd if=/dev/zero of=$TEST_FILE bs=250M count=$COUNTS oflag=direct
    rm $TEST_FILE
}

run ()
{
    COUNTS=50
    disk_load $COUNTS
}

run_benchmark run "disk"
