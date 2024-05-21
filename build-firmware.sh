#!/usr/bin/bash

docker run -it --rm -v `pwd`:/firmware registry.gitlab.com/nsf-noirlab/gemini/rtsw/iocs/gemini-wine/unstable/2022q1 bash -c "cd /firmware && make firmware"
