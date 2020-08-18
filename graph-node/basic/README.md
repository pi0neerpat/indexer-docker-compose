<h1>Graph Node docker-compose - BASIC</h1>

# Table of Contents

<!-- TOC START min:1 max:2 link:true asterisk:false update:true -->

- [Table of Contents](#table-of-contents)
- [Overview](#overview)
  - [Prerequisites](#prerequisites)
- [Route requests with Nginx](#route-requests-with-nginx)
- [Indexer Infrastructure](#indexer-infrastructure)
  - [Start docker-compose](#start-docker-compose)
  - [Deploy your first Subgraph](#deploy-your-first-subgraph)
  - [Deploy the required subgraphs](#deploy-the-required-subgraphs)
  - [Test the Indexer](#test-the-indexer)
- [Next steps](#next-steps)
<!-- TOC END -->

# Overview

1. Provision a server and set up reverse-proxy routing using Nginx
2. Start `graph-node` using `docker-compose`
3. Deploy the "gravity" subgraph to the `graph-node` instance using `httpie`
4. After syncing, query the indexer from your local machine to test that it works

## Prerequisites

### Software

You need the following installed on your server:

- docker
- docker-compose
- nginx
- httpie

### Clone this repo

Clone this repo to `~/indexer-docker-compose` with:

```bash
git clone https://github.com/pi0neerpat/indexer-docker-compose.git ~/indexer-docker-compose
```

### Web3 Provider

You will also need a Web3 Provider. For this tutorial you can use the free Infura tier, however it will not work for any subgraphs except `jannis/gravity`. See the wiki [Setup: Ethereum Nodes and Providers](https://github.com/graphprotocol/mission-control-indexer/wiki/Setup:-Ethereum-Nodes-and-Providers) for more info.

# Route requests with Nginx

Let's expose port `8000` on our domain using Nginx. If you are unfamiliar with using Nginx, I've added a basic outline in the [Nginx folder](../../nginx).

```bash
sudo nano /etc/nginx/sites-enabled/indexer.conf
```

Paste the following, and update your `server_name`. Here we are using the subdomain "indexer".

```js
server {
    # Update your domain here
    server_name indexer.mysite.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

  error_page 404 404.html;

  access_log /var/log/nginx/access.log;
  error_log  /var/log/nginx/error.log;
}
```

Next, check your config is correct and restart the Nginx service

```bash
sudo nginx -t
# nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
# nginx: configuration file /etc/nginx/nginx.conf test is successful

sudo systemctl reload nginx
```

# Indexer Infrastructure

## Start docker-compose

Navigate to this folder and update `docker-compose.yml` with your Infura key:

```yaml
version: "3"
services:
  graph-node:
    image: graphprotocol/graph-node:latest
      # ...
      # UPDATE HERE
      ethereum: "mainnet:https://mainnet.infura.io/v3/<your-key>"
  postgres:
    #...
    environment:
      POSTGRES_USER: graph-node
      POSTGRES_PASSWORD: let-me-in # CHANGE ME
```

Create a folder to hold your Postgres data

```
mkdir ~/subgraph-data/postgres
```

Start the containers using these commands:

```bash
docker-compose up -d

# Then you can inspect logs with
docker-compose logs -f

# If you're having trouble getting it started try restarting with this command
# WARNING!! - may delete all your data and require complete re-syncing
sudo rm -rf data && docker-compose up -d
```

## Deploy your first Subgraph

First, allocate the name of your subgraph on your indexer.

```bash
http post localhost:8020 \
 jsonrpc="2.0" \
 id="1" \
 method="subgraph_create" \
 params:='{"name": "jannis/gravity"}'
```

Next deploy the subgraph located at the ipfs hash

```bash
http post localhost:8020 \
 jsonrpc="2.0" \
 id="1" \
 method="subgraph_deploy" \
 params:='{"name": "jannis/gravity", "ipfs_hash": "QmbeDC4G8iPAUJ6tRBu99vwyYkaSiFwtXWKwwYkoNphV4X"}'
```

If successful, you should see a response like this:

```bash
HTTP/1.1 200 OK
content-length: 199
content-type: application/json; charset=utf-8
date: Tue, 11 Aug 2020 04:01:06 GMT
{
  "id": "1",
  "jsonrpc": "2.0",
  "result": {
    "playground": ":8000/subgraphs/name/jannis/gravity/graphql",
    "queries": ":8000/subgraphs/name/jannis/gravity",
    "subscriptions": ":8001/subgraphs/name/jannis/gravity"
  }
}
```

> :100: PRO-TIP: This approach can be used to deploy any existing subgraph. However, the subgraph data must be actively pinned to the IPFS endpoint specified in `docker-compose.yaml`. If the IPFS endpoint cannot find your subgraph, you will need to use `graph-cli deploy` to pin it to your IPFS endpoint.

Let's check the docker logs to see if our indexer is syncing properly.

```bash
# Get the docker container ID
docker ps
> CONTAINER ID        IMAGE                             COMMAND
> c4b58b9800d1        graphprotocol/graph-node:latest   "/bin/sh -c start"

# Open logs for the container
docker logs c4b5 -f
> Aug 11 03:50:55.775 INFO Scanning blocks [2804111, 2805110], range_size: 1000, subgraph_id: QmbeDC4G8iPAUJ6tRBu99vwyY....
```

## Deploy the required subgraphs

To make things easier, here are the commands to deploy all three subgraphs required for the indexer testnet

```bash
# Moloch
http post localhost:8020 jsonrpc="2.0" id="1" method="subgraph_create" params:='{"name": "molochventures/moloch"}'
http post localhost:8020 jsonrpc="2.0" id="1" method="subgraph_deploy" params:='{"name": "molochventures/moloch", "ipfs_hash": "QmTXzATwNfgGVukV1fX2T6xw9f6LAYRVWpsdXyRWzUR2H9"}'

# Uniswap
http post localhost:8020 jsonrpc="2.0" id="1" method="subgraph_create" params:='{"name": "uniswap/uniswap-v2"}'
http post localhost:8020 jsonrpc="2.0" id="1" method="subgraph_deploy" params:='{"name": "uniswap/uniswap-v2", "ipfs_hash": "QmXKwSEMirgWVn41nRzkT3hpUBw29cp619Gx58XW6mPhZP"}'

# Synthetix
http post localhost:8020 jsonrpc="2.0" id="1" method="subgraph_create" params:='{"name": "synthetixio-team/synthetix"}'
http post localhost:8020 jsonrpc="2.0" id="1" method="subgraph_deploy" params:='{"name": "synthetixio-team/synthetix", "ipfs_hash": "Qme2hDXrkBpuXAYEuwGPAjr6zwiMZV4FHLLBa3BHzatBWx"}'
```

To remove a subgraph, use this command:

```bash
http post localhost:8020 jsonrpc="2.0" id="1" method="subgraph_remove" params:='{"name": "jannis/gravity"}'
```

## Test the Indexer

Great job! Now that you've deployed your subgraph, let's make a call to our indexer to see if it works!

Using your favorite API testing tool, such as [Postman](https://www.postman.com/downloads/), create a query as follows:

| Property     | value                                                     |
| ------------ | --------------------------------------------------------- |
| URL          | `http://indexer.mysite.com/subgraphs/name/jannis/gravity` |
| Request type | POST                                                      |

```graphql
# Query body
query {
  gravatars(first: 5) {
    id
    owner
    displayName
    imageUrl
  }
}
```

You should get a response like this:

> NOTE: It may take up to 20 minutes to start to see any data (32 GB ram, 8 vCPU, Infura). Until then you will probably get a response like `"gravatars": []`

```json
{
  "data": {
    "gravatars": [
      {
        "displayName": "w1m3l",
        "id": "0x10",
        "imageUrl": "https://ucarecdn.com/98c4659f-70e4-4ad3-b7fd-c92ab570344c/-/crop/1114x1115/0,63/-/preview/",
        "owner": "0x2664984287ed631529747ae0c76935e7c9b6e603"
      }
      // ...
    ]
  }
}
```

# Next steps

Superb job! :+1: You've started indexing subgraphs, and can query it using your server's public GraphQL endpoint.

Continue to [Graph Node docker-compose - ADVANCED](../advanced)
