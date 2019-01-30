#!/bin/sh
export PORT=7249
LABEL="ps_exporter"
EXPORTER_PORT=9290
masterIp=$(nmap -oG - -p$PORT "$(hostname -I)"/24 | grep open | awk '{print $2}' | xargs -I '{}' sh -c 'echo "{} $(curl -s http://{}:$PORT/broadcast)"' | grep "exporter-registry" | awk '{print $1}')
echo $masterIp
curl "${masterIp}:${PORT}/register?label=${LABEL}&port=${EXPORTER_PORT}"
/usr/local/ipmi_exporter/ipmi_exporter -config.file /usr/local/ipmi_exporter/ipmi.yml

