FROM registry.redhat.io/ubi9/php-80 AS builder
WORKDIR /overpass/
RUN dnf install -y g++ make expat expat-devel zlib-devel wget tar ; \
    wget https://dev.overpass-api.de/releases/osm-3s_latest.tar.gz ; \
    tar -zxvf osm-3s_latest.tar.gz ; \
    cd osm-3s_v0.7.59 ; \
    ./configure CXXFLAGS="-O2" --prefix=$EXEC_DIR ; \
    make install ; \
    wget https://download.geofabrik.de/europe/monaco-latest.osm.bz2 ; \
    nohup bin/init_osm3s.sh monaco-latest.osm.bz2 $DB_DIR $EXEC_DIR &
    
FROM registry.redhat.io/ubi9/php-80
WORKDIR /overpass/
COPY overpass.conf /etc/httpd/conf/
COPY --from=builder /overpass/osm-3s_v0.7.59/ ./
   
EXPOSE 80

CMD /usr/libexec/s2i/run
