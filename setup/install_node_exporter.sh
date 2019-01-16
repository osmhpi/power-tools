#!/usr/bin/env bash

set -e

# Install dependencies
apt-get -y install curl tar

# Create user
id -u node_exporter &>/dev/null || useradd --no-create-home --shell /bin/false node_exporter

# Download and install
(cd /tmp && curl -LO https://github.com/prometheus/node_exporter/releases/download/v0.15.1/node_exporter-0.15.1.linux-amd64.tar.gz)
tar xvf /tmp/node_exporter-0.15.1.linux-amd64.tar.gz -C /tmp
cp /tmp/node_exporter-0.15.1.linux-amd64/node_exporter /usr/local/bin
rm -rf /tmp/node_exporter-0.15.1.linux-amd64.tar.gz /tmp/node_exporter-0.15.1.linux-amd64

# Create systemd script
cp ./systemd/node_exporter.service /etc/systemd/system/

# Start service
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

# Log service status
systemctl status node_exporter
