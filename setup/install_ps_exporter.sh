#!/usr/bin/env bash

set -e

# Create user
id -u node_exporter &>/dev/null || useradd --no-create-home --shell /bin/false node_exporter

if (systemctl -q is-active ps_exporter)
    then
    systemctl stop ps_exporter
fi

apt-get update
apt-get install curl

# Service
mkdir -p /usr/local/ps_exporter
cp ./ps_exporter/ps_exporter.sh /usr/local/ps_exporter
cp ./systemd/ps_exporter.service /etc/systemd/system/

# Download go bin
cd /tmp
curl -L https://github.com/hpi-power-rangers/ps-exporter/releases/download/v0.0.1/ps-exporter_0.0.1_Linux_amd64.tar.gz > ps-exporter.tar.gz
tar -xzf ps-exporter.tar.gz
cp ./ps-exporter /usr/local/bin/ps_exporter

# Start service
systemctl daemon-reload
systemctl enable ps_exporter
systemctl start ps_exporter

# Log service status
systemctl status ps_exporter
