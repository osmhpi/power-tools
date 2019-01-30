#!/usr/bin/env bash

apt-get install -y adduser libfontconfig

(cd /tmp && wget https://dl.grafana.com/oss/release/grafana_5.4.3_amd64.deb)
dpkg -i /tmp/grafana_5.4.3_amd64.deb

systemctl daemon-reload
systemctl start grafana-server
systemctl status grafana-server
