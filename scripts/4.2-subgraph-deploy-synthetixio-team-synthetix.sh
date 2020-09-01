#!/bin/bash

http post localhost:8120 \
  jsonrpc="2.0" \
  id="1" \
  method="subgraph_deploy" \
  params:='{"name": "synthetixio-team/synthetix", "ipfs_hash": "Qme2hDXrkBpuXAYEuwGPAjr6zwiMZV4FHLLBa3BHzatBWx"}'