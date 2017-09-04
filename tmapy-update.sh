#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -x

export $(cat .env | xargs)

#OSMDATA=europe
export OSMDATA="europe"
export OSMFOLDER=""
export OSMBBOX="8.437507154468175,47.04018649584206,25.312494513946003,52.48277752591322"

docker-compose up -d postgres

wget -q  -O ./data/changes.state.txt "http://download.geofabrik.de/europe-updates/state.txt"
docker run --rm -v $(pwd):/tileset "openmaptiles/import-osm:0.4" osmupdate --verbose --base-url=http://download.geofabrik.de/europe-updates/ --sporadic $( cat ./data/last.state.txt | grep "timestamp=" | cut -d"=" -f 2 | sed -e 's/\\//g' ) /tileset/data/changes-world.osc.gz
docker run --rm -v $(pwd):/tileset "openmaptiles/import-osm:0.4" osmconvert /tileset/data/changes-world.osc.gz -b=${OSMBBOX} --complete-ways --out-osc | gzip > ./data/changes.osc.gz
rm -rf ./data/changes-world.osc.gz

docker-compose run import-osm-diff

# docker-compose run generate-changed-vectortiles
# docker-compose stop postgres
