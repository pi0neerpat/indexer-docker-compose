<h1>Phase 1 - Staking, Basic Actions & Customization</h1>

> :warning: these docs have not been finalized, and are mostly just my notes at the moment

## What is an Indexer Agent?

The indexer agent is a small component that comes with a small database with maybe 200 rows. It doesn't require a lot of CPU, therefore it can be run on the same machine as the graph-nodes.

## Install Indexer Service & Agent

```bash
npm i -g @graphprotocol/indexer-service --registry=https://testnet.thegraph.com/npm-registry
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

TODO

## Indexer Management GF_SERVER_ROOT_URL

port `10000`

- Checks that you have 1,000 Graph tokens

- Continuous checks what subgraphs are deployed, and checks whether they are worth indexing. It will allocate a portion of your stake towards the "interesting" ones.
- Every allocation to a certain subgraph has a limited lifetime. Eventually the feels will go on-chain and be distributed.

## Commands

connect to local indexer mgmt api. can install CLI on server

- install on machine, with port forwarding (ssh -L)

Check that endpoints

```bash
graph indexer status
# Report may not be correct
```

Check that your endpoints are correct:

> main "service": For performing queries
> Block processing "status":Checks health of subgraphs
> State "channels": For payments

## Indexing Rules

```bash
graph indexer --help
```

-`indexer rules set` : set and change rules -`indexer rules start (always)` : always index a subgraph, regardless of parameters

Check current rules with

```bash
indexer rules get [global/all]
```

Set a basic rule

```bash
graph indexer set global minAverageQueryFees 10000
```

```bash
yarn add b258
```
