#!/usr/bin/env bash

curl -LOs https://github.com/hpi-power-rangers/power-tools/releases/download/0.0.1/prometheus.deb

apt install -y -f ./prometheus.deb
