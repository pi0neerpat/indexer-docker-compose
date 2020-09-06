## Install Indexer Service & Agent

Set npm to use The Graph's private package registry. I recommend not using yarn, as it's caused me authentication issues in the past with [Verdaccio](https://verdaccio.org/).

```bash
# Don't use yarn
npm set registry https://testnet.thegraph.com/npm-registry
npm login
```

Install the CLI tools and revert your registry back to the original.

```bash
# Install the latest
npm install -g @graphprotocol/indexer-cli
npm install -g @graphprotocol/indexer-agent
npm install -g @graphprotocol/indexer-service # optional

npm set registry https://registry.npmjs.com/
```

- Postgres for Agent
- Connection to Rinkeby node: Contract interactions-only, no syncing

## Set up Agent configs

TODO

rinkeby node can be frree Infura node!

public indexer url http://localhost:7600

> :warning: this will be made public on-chain!

geo-coordinates useful for customer to decide which indxer to use, based on location

## Running the agent

Pass Rinkeby account mnemonic
Netwoirk subgraph endpoint

## Run the Indexer serive

```bash
./run-indexer-service.sh
```

Provides metrics you can scrape with Prometheus,
Queries can be sent to port `7600`, where to

You should receive Status code `402: Payment required`.

### Set up payments to test a real the query

## Run the Agent

