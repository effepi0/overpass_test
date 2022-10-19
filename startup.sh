#!/bin/bash
nohup /overpass/binaries/bin/dispatcher --osm-base --db-dir=/overpass/db/ &
/usr/libexec/s2i/run
