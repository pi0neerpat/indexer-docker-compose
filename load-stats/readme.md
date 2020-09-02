<h1 align="center">Performance Testing</h1>

This is a dump to determine performace at specific hardware sizes.

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
