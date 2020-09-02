#!/bin/bash

http post localhost:8020 \
 jsonrpc="2.0" \
 id="1" \
 method="subgraph_create" \
 params:='{"name": "jannis/gravity"}'