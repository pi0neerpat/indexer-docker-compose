#!/bin/bash

http post localhost:8120 \
  jsonrpc="2.0" \
  id="1" \
  method="subgraph_deploy" \
  params:='{"name": "molochventures/moloch", "ipfs_hash": "QmTXzATwNfgGVukV1fX2T6xw9f6LAYRVWpsdXyRWzUR2H9"}'