<h1>Graph Node docker-compose - ADVANCED</h1>

# Table of Contents

<!-- TOC START min:1 max:2 link:true asterisk:false update:true -->

- [Table of Contents](#table-of-contents)
- [Outline](#outline)
- [Run separate Indexer and Query nodes](#run-separate-indexer-and-query-nodes)
- [Add Websockets & Health Monitoring](#add-websockets--health-monitoring)
  - [Update Nginx config](#update-nginx-config)
  - [Check Indexer health](#check-indexer-health)
- [Run Postgres as its own service](#run-postgres-as-its-own-service)
- [Bonus: Deploy your own subgraph](#bonus-deploy-your-own-subgraph)
- [Extras](#extras)
- [Next Steps](#next-steps)
<!-- TOC END -->

# Outline

:exclamation: This guide assumes you've completed [Graph Node docker-compose - BASIC](../basic).

Now we need to improve our setup to meet "production" demands

# Run separate Indexer and Query nodes

So far we have been running a `graph-node` in "combined-node" mode. This means it performs both indexing and serving queries.

We need to separate these functions since the demand for each may scale up/down depending on how many subgraphs are syncing, and how many requests we are serving,

Stop your existing graph-nodes, and start the new `docker-compose` in this folder.

```bash
cd ~/indexer-docker-compose/graph-node/basic && docker-compose down

cd ~/indexer-docker-compose/graph-node/advanced && docker-compose up -d
```

Take a look at the new `docker-compose.yml`. We will be creating two separate instances of graph-nodes. One in "query-node" mode, and the other in "index-node" mode.

```yaml
services:
  graph-node-query:
    # ...
    environment:
      node_role: "query-node"
      node_id: "query-node"
  graph-node-indexer:
    # ...
    ports:
      - "8100:8000" # http
      - "8120:8020" # json-rpc
      - "8140:8040" # metrics
    environment:
      node_role: "index-node"
      node_id: "index-node"
      BLOCK_INGESTOR: "index-node"
```

Things to pay attention to:

- Deploying subgraphs is now handled by the "index-node", while queries are handled by the "query-node".
- We are binding the "index-node" to a different set of ports eg. `81XX`. Your create/deploy commands will need to reflect this port change.
- In the BASIC guide we set Postgres to store data in `~/subgraph-data/postgres`. Since we do the same here, we won't lose any existing subgraph sync data.

# Add Websockets & Health Monitoring

## Update Nginx config

In order to support websockets and health monitoring, we must change our Nginx config. Replace the `indexer.conf` you created in the BASIC guide to the final one in the `/nginx` folder of this repo.

```bash
sudo cp ~/indexer-docker-compose/nginx/indexer.conf /etc/nginx/sites-enabled
```

Next update `/etc/nginx/nginx.conf` to add support for [Nginx connection upgrades](http://nginx.org/en/docs/http/websocket.html) as follows:

```bash
sudo sudo nano /etc/nginx/nginx.conf
```

```
http {
  # Add this code block within "http"
  map $http_upgrade $connection_upgrade {
          default upgrade;
          ''      close;
  }
}
```

Excellent! Now we have support for websockets, and we can perform health checks against the query node.

Things to pay attention to:

- Health checks are performed against
- This config only works for the query node on ports `80XX`. You will need to edit it if you want to access your index-node externally.

## Check Indexer health

To check the health and status of a particular subgraph, we use the `index-node/graphql` endpoint. Here is an example of how to check the subgraph `jannis/gravity`:

| Property     | value                                          |
| ------------ | ---------------------------------------------- |
| URL          | `http://indexer.mysite.com/index-node/graphql` |
| Request type | POST                                           |

```graphql
# Query body
{
  indexingStatusForCurrentVersion(subgraphName: "jannis/gravity") {
    synced
    health
    fatalError {
      message
      block {
        number
        hash
      }
      handler
    }
    chains {
      chainHeadBlock {
        number
      }
      latestBlock {
        number
      }
    }
  }
}
```

You should get a response like this:

```json
{
  "data": {
    "indexingStatusForCurrentVersion": {
      "chains": [
        {
          "chainHeadBlock": {
            "number": "10637299"
          },
          "latestBlock": {
            "number": "10637299"
          }
        }
      ],
      "fatalError": null,
      "health": "healthy",
      "synced": true
    }
  }
}
```

Learn more about health checks [here](https://thegraph.com/docs/deploy-a-subgraph#checking-subgraph-health)

# Run Postgres as its own service

The Graph team recommends not running postgres using docker-compose, since it needs to be very stable.

TODO: docs for running Postgres as systemd service

# Bonus: Deploy your own subgraph

In this example we will use the subgraph `jannis/gravity` to demonstrate how you would deploy your own subgraph to your indexer.

```bash
# Install the graph-cli
npm i -g @graphprotocol/graph-cli

git clone https://github.com/Jannis/gravity-subgraph.git && cd gravity-subgraph
```

Now we are ready to push our subgraph to our indexer.

In `package.json`, add the following scripts (don't forget to add a comma in the line above)

```json
"create-indexer": "graph create jannis/gravity --node http://127.0.0.1:8020",
"deploy-indexer": "graph deploy jannis/gravity --debug --ipfs https://testnet.thegraph.com/ipfs/ --node http://127.0.0.1:8020"
```

Now generate the files, and deploy

```bash
yarn
yarn codegen
yarn create-indexer
yarn deploy-indexer
```

If successful, you will see `Deployed to http://127.0.0.1:8000/subgraphs/name/jannis/gravity/graphql`. Check that your subgraph is syncing using docker logs, as mentioned above, and happy querying!

# Extras

### Useful Commands

You may find these useful to check how you server is performing

```bash
# Check Memory
free -m
ps -o pid,user,%mem,command ax | sort -b -k3 -r

# Check Storage
ncdu

# Hardware monitoring dashboard in a terminal
# https://github.com/bcicen/ctop
docker run --rm -ti \
  --name=ctop \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  quay.io/vektorlab/ctop:latest
```

# Next Steps

You are absolutely crushing it! 💪

Continue to [Monitoring Infra](../../monitoring)
