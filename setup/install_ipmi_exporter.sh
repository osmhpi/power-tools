#!/usr/bin/env bash

set -e

# Install dependencies
apt-get -y install freeipmi

# Copy scripts
mkdir -p /usr/local/ipmi_exporter
cp ./ipmi_exporter/* /usr/local/ipmi_exporter
cp ./systemd/ipmi_exporter.service /etc/systemd/system/

# Start service
systemctl daemon-reload
systemctl enable ipmi_exporter
systemctl start ipmi_exporter

# Log service status
systemctl status ipmi_exporter
