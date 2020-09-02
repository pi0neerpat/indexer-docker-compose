#!/bin/bash

echo "NPM_TOKEN: $NPM_TOKEN"

# Indexer agent
docker build \
  --build-arg NPM_TOKEN=$NPM_TOKEN \
  -f Dockerfile.indexer-agent \
  -t indexer-agent:latest \
  .