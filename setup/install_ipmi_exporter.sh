#!/usr/bin/env bash

# Install dependencies
apt-get install freeipmi

# Copy scripts
mkdir /usr/local/ipmi_exporter
cp ./ipmi_exporter/* /usr/local/ipmi_exporter
cp ./systemd/ipmi_exporter.service /etc/systemd/system/

# Start service
systemctl start node_exporter
systemctl daemon-reload

# Log service status
systemctl status node_exporter
