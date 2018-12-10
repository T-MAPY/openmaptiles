#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

./tmapy/europe-prepare-data.sh

./quickstart.sh "europe"

cp ./data/init.state.txt ./data/last.state.txt
