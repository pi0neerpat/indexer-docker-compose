#!/bin/bash

http post <indexer-endpoint>:8030/graphql query='{ indexingStatuses { subgraph node synced fatalError { message } health chains { $
