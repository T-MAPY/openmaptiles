#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -x

docker run -it --rm -v $(pwd)/data:/data -v $(pwd)/tmapy:/tmapy -p 8080:80 klokantech/tileserver-gl --config /tmapy/tileserver-gl/config.json
