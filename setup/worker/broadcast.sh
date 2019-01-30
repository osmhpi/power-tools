nmap -oG - -p7249 "$(hostname -I)"/24 | grep open | awk '{print $2}' | xargs -I '{}' sh -c 'echo "{} $(curl -s http://{}:7249/broadcast)"' | grep "exporter-registry" | awk '{print $1}'
