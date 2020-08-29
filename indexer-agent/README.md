# Setup docker-compose file
## You will need:
- Indexer query node IP
- Ethereum node 
- DB IP
- DB name
- DB username
- DB password

## Create the  DB to be used by the service and agent 
Login into the Postgres container command line
```bash
docker exec [container ID] bash
```
issue the command 

```bash
createdb -U [username] -W [New DB name]
```


Make sure that the wallet used has the GRT token (contact address: 0xa416a7974c2ff62ffa69b2aa8cef78b72326916a )

Please note since the ports 8000,8020 and 8030 are already in use by the the indexer and query node, we have opted to map it top 8200,8220 and 8230

Find out the bridge IPs for the graph query node and database 
```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' [container]
```

Bring the container up 

```bash
docker-compose up -d
```

# Maually Assign GRT


Connect to the agent 

```bash
sudo graph indexer connect http://127.0.0.1:18000
```


Allocate GRT for each subgraph and restart

```bash
sudo graph indexer rules set QmbeDC4G8iPAUJ6tRBu99vwyYkaSiFwtXWKwwYkoNphV4X allocationAmount 10
sudo graph indexer rules set QmTXzATwNfgGVukV1fX2T6xw9f6LAYRVWpsdXyRWzUR2H9 allocationAmount 10
sudo graph indexer rules set Qme2hDXrkBpuXAYEuwGPAjr6zwiMZV4FHLLBa3BHzatBWx allocationAmount 10
sudo graph indexer rules set QmXKwSEMirgWVn41nRzkT3hpUBw29cp619Gx58XW6mPhZP allocationAmount 10

 
sudo graph indexer rules start QmbeDC4G8iPAUJ6tRBu99vwyYkaSiFwtXWKwwYkoNphV4X
sudo graph indexer rules start Qme2hDXrkBpuXAYEuwGPAjr6zwiMZV4FHLLBa3BHzatBWx
sudo graph indexer rules start QmXKwSEMirgWVn41nRzkT3hpUBw29cp619Gx58XW6mPhZP
sudo graph indexer rules start QmTXzATwNfgGVukV1fX2T6xw9f6LAYRVWpsdXyRWzUR2H9

sudo graph indexer rules get all --merged
```

*********************************************************************************

# Route Indexer service requests with Nginx

```bash
sudo nano /etc/nginx/sites-enabled/indexer.conf
```


Paste the following, and update your `URL`. 

```js
server {
    server_name URL;

    location / {
      proxy_pass http://127.0.0.1:7600;
      proxy_http_version 1.1;          
      proxy_set_header Connection $connection_upgrade;
      proxy_set_header Host $host;
      proxy_set_header Upgrade $http_upgrade;
      proxy_cache_bypass $http_upgrade;      
    }
}
```

Reload nginx

```bash
sudo nginx -t
sudo systemctl reload nginx
``` 
 


# Install the graph CLI
 Login to the NPM usig the username and password email to you.
 
 ```bash
 sudo npm login   --registry https://testnet.thegraph.com/npm-registry/
 ```
 
 Install ndexer CLI
 
 ```bash
 sudo npm install -g   --registry https://testnet.thegraph.com/npm-registry/   @graphprotocol/graph-cli@0.19.0-alpha.0   @graphprotocol/indexer-cli
 ```
 
 If facing NPM issues please see https://github.com/graphprotocol/mission-control-indexer/wiki/Troubleshooting
 
# Moment of truth:

 ```bash
 graph indexer connect http://127.0.0.1:18000/
 graph indexer status
 ```

# Add the indexer service to Prometheus

 ```bash
nano prometheus.yml
 ```
 
```js
  - job_name: 'IndexerSerivce'
    metrics_path: /
    static_configs:
      - targets:
        - 172.19.0.1:7300
```
 
