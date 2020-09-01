#!/bin/bash

http post localhost:8120 \
  jsonrpc="2.0" \
  id="1" \
  method="subgraph_create" \
  params:='{"name": "synthetixio-team/synthetix"}'