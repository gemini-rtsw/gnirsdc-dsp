#!/usr/bin/bash
# Assemble the firmware (.lod files) in this repo's dev image, which contains
# gemini-wine (the spec BuildRequires it), with this checkout mounted.
#
#   ./build-firmware.sh
#   IMAGE=<other image with /opt/gemini-wine> ./build-firmware.sh
#
# CI assembles the firmware itself when it builds the RPM; this is for trying a
# change locally. Equivalent to `make firmware` inside
# ./gemini-rtsw-ci/dev_environment.sh --el 9.
set -euo pipefail
IMAGE="${IMAGE:-ghcr.io/gemini-rtsw/gnirsdc-dsp:el9-latest-devel}"
docker run --rm --platform linux/amd64 -u "$(id -u):$(id -g)" \
    -v "$(pwd)":/firmware -w /firmware "$IMAGE" make firmware
