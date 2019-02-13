#!/usr/bin/env bash

curl -LOs https://github.com/hpi-power-rangers/power-tools/releases/download/0.0.1/ipmiexporter-1.0.deb

curl -LOs https://github.com/hpi-power-rangers/power-tools/releases/download/0.0.1/nodeexporter-1.0.deb

curl -LOs https://github.com/hpi-power-rangers/power-tools/releases/download/0.0.1/psexporter-1.0.deb

apt remove -y psexporter
apt remove -y nodeexporter
apt remove -y ipmiexporter

apt install -y -f ./psexporter-1.0.deb
apt install -y -f ./nodeexporter-1.0.deb
apt install -y -f ./ipmiexporter-1.0.deb
