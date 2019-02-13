#!/usr/bin/env bash
REGISTRY_PORT=7249
LABEL="ps_exporter"

HOST=0.0.0.0
PORT=9097

nmap -sT -oG - -p$REGISTRY_PORT "$(hostname -I)"/24 | grep open | awk '{print $2}' | xargs -I '{}' curl -s "http://{}:$REGISTRY_PORT/register?label=$LABEL&port=$PORT"

source /usr/local/ps_exporter/ps_exporter.env
/usr/local/ps_exporter/ps_exporter --host ${HOST} --port ${PORT}
