#!/usr/bin/env bash

# Create user
useradd --no-create-home --shell /bin/false node_exporter

# Download and install
cd /tmp
curl -LO https://github.com/prometheus/node_exporter/releases/download/v0.15.1/node_exporter-0.15.1.linux-amd64.tar.gz
tar xvf /tmp/node_exporter-0.15.1.linux-amd64.tar.gz
cp /tmp/node_exporter-0.15.1.linux-amd64/node_exporter /usr/local/bin
rm -rf /tmp/node_exporter-0.15.1.linux-amd64.tar.gz /tmp/node_exporter-0.15.1.linux-amd64

# Create systemd script

cp ./systemd/node_exporter.service /etc/systemd/system/

# Start service
systemctl start node_exporter
systemctl daemon-reload

# Log service status
systemctl status node_exporter
