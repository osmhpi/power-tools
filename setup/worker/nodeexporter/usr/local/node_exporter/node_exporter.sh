#!/usr/bin/env bash
export REGISTRY_PORT=7249
LABEL="node_exporter"

PORT=9100

masterIp=$(nmap -oG - -p$REGISTRY_PORT "$(hostname -I)"/24 | grep open | awk '{print $2}' | xargs -I '{}' sh -c 'echo "{} $(curl -s http://{}:$REGISTRY_PORT/broadcast)"' | grep "exporter-registry" | awk '{print $1}')
echo $masterIp
curl "${masterIp}:${REGISTRY_PORT}/register?label=${LABEL}&port=${PORT}"

source /usr/local/node_exporter/node_exporter.env
/usr/local/bin/node_exporter --web.listen-address=":${PORT}"
