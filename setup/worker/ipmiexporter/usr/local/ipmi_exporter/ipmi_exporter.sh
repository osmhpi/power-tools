#!/usr/bin/env bash
REGISTRY_PORT=7249
LABEL="ipmi_exporter"

PORT=9290

nmap -sT -oG - -p$REGISTRY_PORT "$(hostname -I)"/24 | grep open | awk '{print $2}' | xargs -I '{}' curl -s "http://{}:$REGISTRY_PORT/register?label=$LABEL&port=$PORT"

[ -f /usr/local/ipmi_exporter/ipmi_exporter.env ] && . /usr/local/ipmi_exporter/ipmi_exporter.env
/usr/local/ipmi_exporter/ipmi_exporter -config.file /usr/local/ipmi_exporter/ipmi.yml --web.listen-address=":${PORT}"
