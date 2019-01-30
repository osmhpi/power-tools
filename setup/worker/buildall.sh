#!/usr/bin/env bash

dpkg-deb --build psexporter
dpkg-deb --build nodeexporter
dpkg-deb --build ipmiexporter
