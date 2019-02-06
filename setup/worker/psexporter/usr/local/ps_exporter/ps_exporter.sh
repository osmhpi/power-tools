#!/usr/bin/env bash
export REGISTRY_PORT=7249
LABEL="ps_exporter"

HOST=0.0.0.0
PORT=9097

masterIp=$(nmap -oG - -p$REGISTRY_PORT "$(hostname -I)"/24 | grep open | awk '{print $2}' | xargs -I '{}' sh -c 'echo "{} $(curl -s http://{}:$REGISTRY_PORT/broadcast)"' | grep "exporter-registry" | awk '{print $1}')
echo $masterIp
curl "${masterIp}:${REGISTRY_PORT}/register?label=${LABEL}&port=${PORT}"

source /usr/local/ps_exporter/ps_exporter.env
/usr/local/ps_exporter/ps_exporter --host ${HOST} --port ${PORT}
