#!/usr/bin/env bash

curl -LOs https://github.com/hpi-power-rangers/power-tools/releases/download/0.0.1/ipmiexporter.deb

curl -LOs https://github.com/hpi-power-rangers/power-tools/releases/download/0.0.1/nodeexporter.deb

curl -LOs https://github.com/hpi-power-rangers/power-tools/releases/download/0.0.1/psexporter.deb

apt install -y -f ./psexport.deb
apt install -y -f ./nodeexporter.deb
apt install -y -f ./ipmiexporter.deb
