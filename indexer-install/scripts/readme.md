The convenience scripts and documentation here was contributed by @pkrasam

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
