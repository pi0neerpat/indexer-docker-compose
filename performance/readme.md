<h1 align="center">Performance Testing</h1>

Eventually this is where I'll discuss performance enhanecements. For now it is just notes from my own testing at specific hardware sizes.

---

> I haven't completed testing yet! Stay tuned

# Methods

Using phase 0 test harness https://github.com/graphprotocol/mission-control-indexer/tree/master/testing/phase0. Note that queries are duplicated, so this does not really approximate actual usage.

```bash
npm install -g typescript ts-node
```

Check a test passes with `cat report.csv`

All tested with:

- single indexer node, single query node
- active indexer with fully synced moloch and uniswap

# Results

## Standard phase 0 harness

300s test: `./cli test --output report.csv indexers.csv queries.csv | tee report.md`

| Hardware   | RAM Baseline | RAM Load | System Baseline | System Load | req/min |
| :--------- | :----------- | :------- | --------------- | ----------- | ------- |
| 32GB 8vCPU | 1.81GB       | 1.79GB   | 5%              | 47%         | 99      |
| 8GB 4vCPU  | 1.38GB       | GB       | 6%              | %           |         |

## Increase connections

```bash
./cli test --output report.csv --duration 120 \
--max-error-rate .0005 \
--min-request-rate 10 \
--connections-per-indexer 100 \
indexers.csv queries.csv | tee report.md
```

| Hardware   | RAM Baseline | RAM Load | System Baseline | System Load | req/min |
| :--------- | :----------- | :------- | --------------- | ----------- | ------- |
| 32GB 8vCPU | 1.81GB       | 1.9GB    | 4%              | 45%         | 190     |
| 8GB 4vCPU  | 2.15GB       | 2.17GB   | 6%              | 24%         | FAILED  |

- Increasing connections per indexer by 10x only doubled req/min

## Lower error rate 0.005%

```bash
./cli test --output report.csv --duration 120 \
--max-error-rate .000005 \
--min-request-rate 10 \
--connections-per-indexer 100 \
indexers.csv queries.csv | tee report.md
```

| Hardware   | RAM Baseline | RAM Load | System Baseline | System Load | req/min |
| :--------- | :----------- | :------- | --------------- | ----------- | ------- |
| 32GB 8vCPU | 1.81GB       | 1.96GB   | 4%              | 40%         | 198     |

## Increase req rate

```bash
./cli test --output report.csv --duration 120 \
--max-error-rate .000005 \
--min-request-rate 100 \
--connections-per-indexer 10 \
indexers.csv queries.csv | tee report.md
```

| Hardware   | RAM Baseline | RAM Load | System Baseline | System Load | req/min |
| :--------- | :----------- | :------- | --------------- | ----------- | ------- |
| 32GB 8vCPU | 1.81GB       | 1.92     | 4%              | 47%         | 124     |

## High req rate and connections

```bash
./cli test --output report.csv --duration 120 \
--max-error-rate .000005 \
--min-request-rate 100 \
--connections-per-indexer 100 \
indexers.csv queries.csv | tee report.md
```

| Hardware   | RAM Baseline | RAM Load | System Baseline | System Load | req/min |
| :--------- | :----------- | :------- | --------------- | ----------- | ------- |
| 32GB 8vCPU | 1.81GB       | 1.94     | 4%              | 42          | 203     |

## 5 min - 100 connections

```bash
./cli test --output report.csv --duration 300 \
--max-error-rate .000005 \
--min-request-rate 10 \
--connections-per-indexer 100 \
indexers.csv queries.csv | tee report.md
```

| Hardware   | RAM Baseline | RAM Load | System Baseline | System Load | req/min |
| :--------- | :----------- | :------- | --------------- | ----------- | ------- |
| 32GB 8vCPU | 1.81GB       | 1.95     | 4%              | 48          | 220     |

## 5 min - 2 machines with 200 connections

```bash
./cli test --output report.csv --duration 300 \
--max-error-rate .000005 \
--min-request-rate 10 \
--connections-per-indexer 100 \
indexers.csv queries.csv | tee report.md
```

| Hardware   | RAM Baseline | RAM Load | System Baseline | System Load | req/min |
| :--------- | :----------- | :------- | --------------- | ----------- | ------- |
| 32GB 8vCPU | 1.9GB        | 2.0      | 3%              | 78%         | 1,000   |

## 5 min - 3 machines with 300 connections

```bash
./cli test --output report.csv --duration 300 \
--max-error-rate .000005 \
--min-request-rate 10 \
--connections-per-indexer 100 \
indexers.csv queries.csv | tee report.md
```

| Hardware   | RAM Baseline | RAM Load | System Baseline | System Load | req/min |
| :--------- | :----------- | :------- | --------------- | ----------- | ------- |
| 32GB 8vCPU | 1.9GB        | 2.01     | 3%              | 81          | 1,100   |

## 5 min - 3 machines with 900 connections

```bash
./cli test --output report.csv --duration 300 \
--max-error-rate .000005 \
--min-request-rate 10 \
--connections-per-indexer 300 \
indexers.csv queries.csv | tee report.md
```

| Hardware   | RAM Baseline | RAM Load | System Baseline | System Load | req/min |
| :--------- | :----------- | :------- | --------------- | ----------- | ------- |
| 32GB 8vCPU | 1.89GB       | 2.0      | 3%              | 82%         | 850     |

- This is 900 connections for a single indexer. Not sure that is even supported?
- Internal server error on grafana - "Annotation query failed"

## 5 min - 2 machines with 300 connections

```bash
./cli test --output report.csv --duration 300 \
--max-error-rate .000005 \
--min-request-rate 10 \
--connections-per-indexer 150 \
indexers.csv queries.csv | tee report.md
```

| Hardware   | RAM Baseline | RAM Load | System Baseline | System Load | req/min |
| :--------- | :----------- | :------- | --------------- | ----------- | ------- |
| 32GB 8vCPU | 1.89GB       | 1.93     | 3%              | 80%         | 950     |

## 5 min - 4 machines with 400 connections

```bash
./cli test --output report.csv --duration 300 \
--max-error-rate .000005 \
--min-request-rate 10 \
--connections-per-indexer 100 \
indexers.csv queries.csv | tee report.md
```

| Hardware   | RAM Baseline | RAM Load | System Baseline | System Load | req/min |
| :--------- | :----------- | :------- | --------------- | ----------- | ------- |
| 32GB 8vCPU | 1.8GB        | 2.03     | 3%              | 78%         | 1,000   |

## Add a second query node?

TODO:

- use Traefik to set up multiple index nodes and try to increase req/min beyond 1k
- Change postgres config to allow more connections
- Does query node have some setting for connections. Couldn't find it in graph-node docs. Check my other notes

# Picking a smaller server

- Total db is 98GB for the phase 0 subgraphs, so likely will need 1TB. Unless I don't keep blocks. Will have to check whether this indeed does degrade performance if the archive node is nearby (!)
- Choosing the \$40/mo DO droplet has 4vCPU, 8GB RAM, 160GB SSD, which seems like enough
- Similar server on Hetzner Cloud is 12 EUR (\$14)
- For comparable price of 34 EUR, can get a Hetzner Dedicated AX41-NVMe has 64 GB RAM, 6 CPU, 2x512GB SSD.
