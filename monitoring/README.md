<h1>Monitoring Infra</h1>

## Set up Grafana and Prometheus

First create a prometheus config file. We need to know the bride IP of the indexer node.

```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' 5bd
> 172.17.0.1
```

Next, we use this to create the `prometheus.yml`, which tells prometheus to scrap the indexer node for data.

```bash
mkdir ~/indexer/monitoring/ && nano ~/indexer/monitoring/prometheus.yml
```

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:

alerting:

scrape_configs:
  - job_name: "thegraph"
    static_configs:
      - targets:
          - 172.26.0.1:8140 # CHANGE THIS
        # Might also be port 8140 if you separated query and index nodes
        # localhost:8140
```

Now, in the same directory as `prometheus.yml` create a new docker-compose file to launch Grafana and Prometheus

```bash
cd ~/indexer/monitoring && nano docker-compose.yml
```

```yaml
version: "3.2"
services:
  grafana:
    image: grafana/grafana:6.4.4
    ports:
      - "3000:3000"
    volumes:
      - type: bind
        source: /docker/volumes/grafana/data/
        target: /var/lib/grafana
      - type: bind
        source: /docker/volumes/grafana/log/
        target: /var/log/grafana
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
      GF_ANALYTICS_REPORTING_ENABLED: "false"
      GF_SERVER_DOMAIN: "grafana.mysite.com"
      GF_SERVER_ROOT_URL: "https://grafana.mysite.com"
    network_mode: bridge
    restart: unless-stopped
    # mem_limit: 4G
    # mem_reservation: 16M
  prometheus:
    image: prom/prometheus:v2.20.1
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - "--storage.tsdb.retention.time=120d"
      - "--web.console.libraries=/usr/share/prometheus/console_libraries"
      - "--web.console.templates=/usr/share/prometheus/consoles"
    volumes:
      - type: "bind"
        source: $HOME/monitoring-data/prometheus
        target: /prometheus
      - type: "bind"
        source: $HOME/indexer/monitoring/prometheus.yml
        target: /etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
    network_mode: bridge
    restart: unless-stopped
```

And set the approriate permissions

```bash
sudo chown 472:472 -R /docker/volumes

# create some directories
mkdir ~/monitoring-data
mkdir ~/monitoring-data/prometheus
sudo chown 65534:65534 $HOME/monitoring-data/prometheus
```

Now start it up.

```bash
docker-compose up -d
```

From your local machine, you can try to create a tunnel to port `3000` to see the Grafana dashboard

```bash
ssh -L 127.0.0.1:8000:127.0.0.1:3000 user@yournode
```

Next we need to permanently expose port `3000` to the world, so let's add a server block to our `/etc/nginx/sites-enabled/indexer.conf`

```conf
server {
    server_name grafana.mysite.com;

    location / {
      proxy_pass http://127.0.0.1:3000;
      proxy_http_version 1.1;
      proxy_set_header Connection $connection_upgrade;
      proxy_set_header Host $host;
      proxy_set_header Upgrade $http_upgrade;
      proxy_cache_bypass $http_upgrade;
    }
}
```

Deploy your changes:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

Now we need Certbot to issue a certificate. You probably only need it for the grafana domain for now.

```
# Install
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx
# Run
sudo certbot --nginx certonly
```

Then, its back to your indexer.conf for one final update

```
server {
    server_name grafana.mysite.com;

    location / {
      proxy_pass http://127.0.0.1:3000;
      proxy_http_version 1.1;
      proxy_set_header Connection $connection_upgrade;
      proxy_set_header Host $host;
      proxy_set_header Upgrade $http_upgrade;
      proxy_cache_bypass $http_upgrade;
    }
    listen 443 ssl http2; # managed by Certbot
    ssl on;

    # Change server name here
    ssl_certificate /etc/letsencrypt/live/grafana.mysite.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/grafana.mysite.com/privkey.pem;

    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
  # Change server name here
  if ($host = grafana.mysite.com) {
    return 301 https://$host\$request_uri;
    } # managed by Certbot

  listen 80;

  # Change server name here
  server_name grafana.mysite.com;
  return 404; # managed by Certbot
}
```

And deploy!

```bash
sudo nginx -t
sudo systemctl reload nginx
```

Now you should see your grafana instance at `grafana.mysite.com`

## Create the grafana dashboards

### Add data sources

First get the docker bridge address for our containers.

```bash
docker ps
> ... docker container IDs

# Get the specific address for a container
docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' <container id>
> 172.17.0.1
```

#### Postgres

1. Optional, but recommended: Create a postgres user with limited permissions. (You may need to stop your graph nodes first)

```bash
# Enter the docker container
docker exec -it <container-id> bash

# Switch users
su postgres

# open postgres cli and create a new user
postgres
CREATE USER grafana WITH PASSWORD 'grafana';
```

2. Add the user in the postgres data source

Should be named (lowercase) "postgres". URL will look like `172.17.0.1:5432`

#### Prometheus

Should be named (lowercase) "prometheus". URL will look like `172.17.0.1:9090`

### Add the dashboards

On the `/Dashboards`, there is a "import" button which you will use to create new dashboards. Paste in the code from the JSON files for each: [indexing.json](https://gist.github.com/pi0neerpat/b4e2efd11531d3b872455fcaaeb06dd8), [metrics.json](https://gist.github.com/pi0neerpat/5c469d7ffe850b34c7b245be48f51706), [postgres.json](https://gist.github.com/pi0neerpat/9e9e2356b2e7db37e05173e03fa9a662).

## Expose your Prometheus endpoint

You should know have the hang of this by now!

```
server {
    server_name prometheus.mysite.com;

    location / {
      proxy_pass http://127.0.0.1:9090;
      proxy_http_version 1.1;
      proxy_set_header Connection $connection_upgrade;
      proxy_set_header Host $host;
      proxy_set_header Upgrade $http_upgrade;
      proxy_cache_bypass $http_upgrade;
    }
}
```

Wow, look how far you made it. You did some very difficult and impressive stuff today. You are an incredible person, and deserve a special treat!
