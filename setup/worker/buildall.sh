#!/usr/bin/env bash

VERSION="1.0"

dpkg-deb --build psexporter
dpkg-deb --build nodeexporter
dpkg-deb --build ipmiexporter

mv psexporter.deb "psexporter-$VERSION.deb"
mv nodeexporter.deb "nodeexporter-$VERSION.deb"
mv ipmiexporter.deb "ipmiexporter-$VERSION.deb"
