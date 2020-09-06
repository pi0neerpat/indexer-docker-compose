#!/bin/bash

http post localhost:8020 \
 jsonrpc="2.0" \
 id="1" \
 method="subgraph_deploy" \
 params:='{"name": "jannis/gravity", "ipfs_hash": "QmbeDC4G8iPAUJ6tRBu99vwyYkaSiFwtXWKwwYkoNphV4X"}'