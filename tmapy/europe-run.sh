#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

export OSMDATA=europe
export OSMFOLDER=""
export OSMBBOX="8.437507154468175,47.04018649584206,25.312494513946003,52.48277752591322"
export MIN_ZOOM=0 
export MAX_ZOOM=14 
export QUICKSTART_MAX_ZOOM=${MAX_ZOOM}

./tmapy/europe-prepare-data.sh

./quickstart.sh "europe"

cp ./data/init.state.txt ./data/last.state.txt
