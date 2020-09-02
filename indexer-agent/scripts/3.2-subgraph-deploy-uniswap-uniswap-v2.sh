#!/bin/bash

http post localhost:8120 \
  jsonrpc="2.0" \
  id="1" \
  method="subgraph_deploy" \
  params:='{"name": "uniswap/uniswap-v2", "ipfs_hash": "QmXKwSEMirgWVn41nRzkT3hpUBw29cp619Gx58XW6mPhZP"}'