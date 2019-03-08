#!/usr/bin/env bash
REGISTRY_PORT=7249
LABEL="node_exporter"

PORT=9100

nmap -sT -oG - -p$REGISTRY_PORT "$(hostname -I)"/24 | grep open | awk '{print $2}' | xargs -I '{}' curl -s "http://{}:$REGISTRY_PORT/register?label=$LABEL&port=$PORT"

[ -f /usr/local/node_exporter/node_exporter.env ] && . /usr/local/node_exporter/node_exporter.env
/usr/local/bin/node_exporter --web.listen-address=":${PORT}"
