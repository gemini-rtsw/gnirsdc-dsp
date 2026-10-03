#!/usr/bin/bash
# Assemble the firmware (.lod files) with the DSP56K tools under Wine.
#
#   WINE_IMAGE=<image with gemini-wine> ./build-firmware.sh
#
# gemini-wine has not been migrated to GitHub/GHCR, so there is no default
# image: point WINE_IMAGE at one that provides
# /gem_base/epics/ioc/gemini-wine/wine-7.0/wine (see Makefile). Commit the
# resulting .lod files; CI packages what is committed.
set -euo pipefail
: "${WINE_IMAGE:?set WINE_IMAGE to an image providing gemini-wine (see the comment in this script)}"
docker run -it --rm -v "$(pwd)":/firmware "$WINE_IMAGE" bash -c "cd /firmware && make firmware"
