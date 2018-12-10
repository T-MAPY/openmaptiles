#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -x

#cd /opt/openmaptiles

export $(cat .env | xargs)

export OSMDATA="europe"
export OSMFOLDER=""
export OSMBBOX="8.437507154468175,47.04018649584206,25.312494513946003,52.48277752591322"

mkdir -p ./data

if [ -f ./data/${OSMDATA}-latest.osm.pbf.backup ]; then
    mv ./data/${OSMDATA}-latest.osm.pbf.backup ./data/${OSMDATA}-latest.osm.pbf
fi

# download
if [ !  -f ./data/${OSMDATA}-latest.osm.pbf ]; then
    wget -O ./data/init.state.txt "http://download.geofabrik.de/europe-updates/state.txt"
    wget -O ./data/${OSMDATA}-latest.osm.pbf -c "http://download.geofabrik.de/${OSMFOLDER}${OSMDATA}-latest.osm.pbf"
else
    echo "The ./data/${OSMDATA}-latest.osm.pbf exists, we don't need to download! "
fi

# clip
if [ !  -f ./data/${OSMDATA}.osm.pbf ]; then
    docker-compose run --rm import-osm osmconvert /import/${OSMDATA}-latest.osm.pbf -b=${OSMBBOX} --out-pbf -o=/import/${OSMDATA}.osm.pbf
else
    echo "The ./data/${OSMDATA}.osm.pbf exists, we don't need to clip it! "
fi

if [ !  -f ./data/${OSMDATA}-latest.osm.pbf ]; then
    mv ./data/${OSMDATA}-latest.osm.pbf ./data/${OSMDATA}-latest.osm.pbf.backup
fi

docker-compose run --rm import-osm osmconvert --out-statistics /import/${OSMDATA}.osm.pbf  > ./data/osmstat.txt

lon_min=$( cat ./data/osmstat.txt | grep "lon min:" | cut -d":" -f 2 | xargs | tr -d '\r\n' )
lon_max=$( cat ./data/osmstat.txt | grep "lon max:" | cut -d":" -f 2 | xargs | tr -d '\r\n' )
lat_min=$( cat ./data/osmstat.txt | grep "lat min:" | cut -d":" -f 2 | xargs | tr -d '\r\n' )
lat_max=$( cat ./data/osmstat.txt | grep "lat max:" | cut -d":" -f 2 | xargs | tr -d '\r\n' )
timestamp_max=$( cat ./data/osmstat.txt | grep "timestamp max:" | cut -d" " -f 3 | xargs | tr -d '\r\n' )

cat > ./data/docker-compose-config.yml  <<- EOM
version: "2"
services:
  generate-vectortiles:
    environment:
      BBOX: "$lon_min,$lat_min,$lon_max,$lat_max"
      OSM_MAX_TIMESTAMP : "$timestamp_max"
      OSM_AREA_NAME: "$OSMDATA"
      MIN_ZOOM: "$QUICKSTART_MIN_ZOOM"
      MAX_ZOOM: "$QUICKSTART_MAX_ZOOM"
EOM
