<h1 align="center">Performance Testing</h1>

This is a dump to determine performace at specific hardware sizes.

```bash
npm install -g typescript ts-node
```

Check a test passes with `cat report.csv`

## Standard phase 0 harness

300s test: `./cli test --output report.csv indexers.csv queries.csv | tee report.md`

| Hardware   | RAM Baseline | RAM Load | System Baseline | System Load | req/min |
| :--------- | :----------- | :------- | --------------- | ----------- | ------- |
| 32GB 8vCPU | 1.81GB       | 1.79GB   | 5%              | 47%         | 99      |

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

## 5 min - high connections

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

## 5 min - test from 2 different machines

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

## 5 min - test from 3 different machines

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

## 5 min - 3 machines with more connections

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

## 5 min - 2 machines with 300 connections total

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

## Add a second query node?

TODO:

- use Traefik to set up multiple index nodes and try to increase req/min beyond 1k
- Change postgres config to allow more connections
- Does query node have some setting for connections. Couldn't find it in graph-node docs. Check my other notes
