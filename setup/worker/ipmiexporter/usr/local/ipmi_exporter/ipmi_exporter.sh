#!/usr/bin/env bash
export REGISTRY_PORT=7249
LABEL="ps_exporter"

PORT=9290

masterIp=$(nmap -oG - -p$REGISTRY_PORT "$(hostname -I)"/24 | grep open | awk '{print $2}' | xargs -I '{}' sh -c 'echo "{} $(curl -s http://{}:$REGISTRY_PORT/broadcast)"' | grep "exporter-registry" | awk '{print $1}')
echo $masterIp
curl "${masterIp}:${REGISTRY_PORT}/register?label=${LABEL}&port=${PORT}"

source /usr/local/ipmi_exporter/ipmi_exporter.env
/usr/local/ipmi_exporter/ipmi_exporter -config.file /usr/local/ipmi_exporter/ipmi.yml --web.listen-address=":${PORT}"
