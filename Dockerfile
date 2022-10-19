FROM registry.access.redhat.com/ubi9/php-80 AS builder
USER root
WORKDIR /overpass/
RUN dnf install -y g++ make expat expat-devel zlib-devel wget tar ; \
    mkdir db ; \
    mkdir binaries ; \
    wget https://dev.overpass-api.de/releases/osm-3s_latest.tar.gz ; \
    tar -zxvf osm-3s_latest.tar.gz ; \
    cd osm-3s_v0.7.59 ; \
    ./configure CXXFLAGS="-O2" --prefix=/overpass/binaries/ ; \
    make install ; \
    wget https://download.geofabrik.de/europe/monaco-latest.osm.bz2 ; \
    nohup bin/init_osm3s.sh monaco-latest.osm.bz2 /overpass/db/ /overpass/binaries/ &
    
FROM registry.access.redhat.com/ubi9/php-80
USER root
WORKDIR /overpass/
RUN mkdir db ; \
    mkdir binaries ; \
    mkdir startup    
COPY overpass.conf /etc/httpd/conf.d/
COPY --from=builder /overpass/osm-3s_v0.7.59/ ./
COPY --from=builder /overpass/db/ ./db/
COPY --from=builder /overpass/binaries/ ./binaries/
RUN nohup /overpass/binaries/bin/dispatcher --osm-base --db-dir=/overpass/db/ &
   
EXPOSE 80

CMD /usr/libexec/s2i/run
