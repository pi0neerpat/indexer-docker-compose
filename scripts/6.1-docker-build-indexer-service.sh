#!/bin/bash

echo "NPM_TOKEN: $NPM_TOKEN"

# Indexer service
docker build \
  --build-arg NPM_TOKEN=$NPM_TOKEN \
  -f Dockerfile.indexer-service \
  -t indexer-service:latest \
  .