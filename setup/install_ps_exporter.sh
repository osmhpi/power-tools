#!/usr/bin/env bash

set -e

# Create user
id -u node_exporter &>/dev/null || useradd --no-create-home --shell /bin/false node_exporter

apt-get update

# Required for add-apt-repository
apt-get install -y software-properties-common

# install go
add-apt-repository -y ppa:longsleep/golang-backports
apt-get install -y golang-go

# Service
mkdir -p /usr/local/ps_exporter
cp ./ps_exporter/ps_exporter.sh /usr/local/ps_exporter
cp ./systemd/ps_exporter.service /etc/systemd/system/

# Download go bin
cd /tmp
export GOPATH=/tmp
go get github.com/hpi-power-rangers/ps-exporter
cp /tmp/bin/ps-exporter /usr/local/bin/ps_exporter

# Start service
systemctl daemon-reload
systemctl enable ps_exporter
systemctl start ps_exporter

# Log service status
systemctl status ps_exporter
