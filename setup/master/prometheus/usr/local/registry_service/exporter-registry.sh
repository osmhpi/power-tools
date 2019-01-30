#!/bin/sh

/usr/local/registry_service/exporter-registry --port 7249 --out /etc/prometheus/targets.json
