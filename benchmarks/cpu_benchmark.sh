#!/usr/bin/env bash
source ./run_benchmark.sh

run ()
{
    STEPS=1
    MAX_CORES=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l) 
    for i in $(seq 1 $STEPS $MAX_CORES)
    do 
        stress-ng --cpu $i --cpu-method matrixprod --metrics-brief --perf -t 60
    done
}

run_benchmark run "cpu"
