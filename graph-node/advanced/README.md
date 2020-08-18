<h1>Graph Node docker-compose - ADVANCED</h1>

# Table of Contents

<!-- TOC START min:1 max:2 link:true asterisk:false update:true -->
- [Table of Contents](#table-of-contents)
- [Outline](#outline)
- [Run separate Indexer and Query nodes](#run-separate-indexer-and-query-nodes)
- [Add Websocket support, and enable health monitoring](#add-websocket-support-and-enable-health-monitoring)
  - [Check Indexer health](#check-indexer-health)
- [Run Postgres as its own service](#run-postgres-as-its-own-service)
- [Bonus: Deploy your own subgraph](#bonus-deploy-your-own-subgraph)
- [Extras](#extras)
- [Next Steps](#next-steps)
<!-- TOC END -->

# Outline

:exclamation: This guide assumes you've completed [Graph Node docker-compose - BASIC](../basic).

Now we need to improve our setup to meet "production" demands. In this section we will cover the following:

- Add Websocket support
- Add Indexer health monitoring
- Use separate nodes for indexing and querying
- Harden the Postgres database
- bonus: Deploy your _own subgraph_ to your _own Indexer node_

# Run separate Indexer and Query nodes

So far we have been running a `graph-node` in "combined-node" mode. This means it performs both indexing and serving queries. Since the demand for each may scale up/down depending on how many subgraphs are syncing, and how many requests we are serving, we need to separate these functions.

Update `docker-compose.yaml` to create two separate graph-nodes- one in "query-node" mode, and the other in "index-node" mode.

```yaml
version: "3"
services:
  # Query
  # adapted from https://github.com/graphprotocol/mission-control-indexer/blob/8cc08c4c72ed7a7fcab2bfeace172626c9d08ee3/k8s/base/query-node/deployment.yaml
  graph-node-query:
    image: graphprotocol/graph-node:latest
    ports:
      - "8000:8000" # http
      - "8001:8001" # ws
      - "8030:8030" # index-node
    depends_on:
      - postgres
    environment:
      postgres_host: postgres:5432
      postgres_user: graph-node
      postgres_pass: let-me-in
      postgres_db: graph-node
      ipfs: "https://testnet.thegraph.com/ipfs/"
      ethereum: "mainnet:<your-web3-provider>"
      node_role: "query-node"
      node_id: "query-node"
      GRAPH_KILL_IF_UNRESPONSIVE: "true"
      EXPERIMENTAL_SUBGRAPH_VERSION_SWITCHING_MODE: "synced" # ?
      RUST_LOG: info
    restart: always
  # Index
  # adapted from https://github.com/graphprotocol/mission-control-indexer/blob/8cc08c4c72ed7a7fcab2bfeace172626c9d08ee3/k8s/base/index-node/stateful_set.yaml
  graph-node-indexer:
    image: graphprotocol/graph-node:latest
    ports:
      - "8100:8000" # http
      - "8120:8020" # json-rpc
      - "8140:8040" # metrics
    depends_on:
      - postgres
    environment:
      postgres_host: postgres:5432
      postgres_user: graph-node
      postgres_pass: let-me-in
      postgres_db: graph-node
      ipfs: "https://testnet.thegraph.com/ipfs/"
      ethereum: "mainnet:<your-web3-provider>"
      node_role: "index-node"
      node_id: "index-node"
      BLOCK_INGESTOR: "index-node" # Only need to specify one block ingestor
      GRAPH_KILL_IF_UNRESPONSIVE: "true"
      RUST_LOG: info
    restart: always

  postgres:
    image: postgres
    ports:
      - "5432:5432"
    command: ["postgres", "-cshared_preload_libraries=pg_stat_statements"]
    environment:
      POSTGRES_USER: graph-node
      POSTGRES_PASSWORD: let-me-in
      POSTGRES_DB: graph-node
    volumes:
      - ~/subgraph-data/postgres:/var/lib/postgresql/data
    restart: always
```

A couple things to note here:

- Earlier we set postgres to store data in `~/subgraph-data/postgres`. As long as we do the same here, we won't lose any existing subgraph data.
- We have to bind the second index-node to a different set of ports eg. `81XX`. Your create/deploy commands will need to be updated to reflect this.
- You should deploy to the index-node, and serve queries to the query-node.

# Add Websocket support, and enable health monitoring

In order to support websockets and access health monitoring, we must change our Nginx config. First update the original `indexer.conf` you created earlier to the following:

```yaml
  server {
    server_name indexer.mysite.com;

    location ^~ /index-node/ {
      # Remove the /index-node/ again
      rewrite ^/index-node/(.*)$ /$1 break;

      # Proxy configuration.
      proxy_pass http://127.0.0.1:8030;
      proxy_http_version 1.1;
      proxy_set_header Connection $connection_upgrade;
      proxy_set_header Host $host;
      proxy_set_header Upgrade $http_upgrade;
      proxy_cache_bypass $http_upgrade;

      # Gateway timeout.
      proxy_read_timeout 30s;
      proxy_send_timeout 30s;
    }

    location /nginx_status {
      stub_status;
      allow 127.0.0.1;
      deny all;
    }

    location / {
      location = / {
        return 200;
      }

      # Move WebSocket and HTTP requests into /ws/ and /http/ prefixes;
      # this allows us to forward both types of requests to different
      # query node ports
      if ( $connection_upgrade = "upgrade" ) {
        rewrite ^(.*)$ /ws/$1;
      }
      if ( $connection_upgrade != "upgrade" ) {
        rewrite ^(.*)$ /http/$1;
      }

      location /http/ {
        # Remove the /http/ again
        rewrite ^/http/(.*)$ $1 break;

        # Proxy configuration.
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_cache_bypass $http_upgrade;
        proxy_next_upstream error invalid_header http_502;

        # Gateway timeout.
        proxy_read_timeout 30s;
        proxy_send_timeout 30s;
      }

      location /ws {
        # Remove the /ws/ again
        rewrite ^/ws/(.*)$ $1 break;

        # Proxy configuration.
        proxy_pass http://127.0.0.1:8001;
        proxy_http_version 1.1;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_cache_bypass $http_upgrade;

        # Gateway timeout.
        proxy_read_timeout 1800s;
        proxy_send_timeout 1800s;
      }
    }

    error_page 404 404.html;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
  }
```

Next you need to update `/etc/nginx/nginx.conf` to add support for [connection upgrades](http://nginx.org/en/docs/http/websocket.html) as follows:

```
http {
  # existing config...

  map $http_upgrade $connection_upgrade {
          default upgrade;
          ''      close;
  }
}
```

Now we have support for websockets, and we can make health checks against the query node. A couple caveats here:

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
