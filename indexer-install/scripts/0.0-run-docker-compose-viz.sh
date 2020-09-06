#!/bin/bash

docker run --rm -it --name dcv -v $(pwd):/input pmsipilot/docker-compose-viz render -m image ./docker-compose.yml
