<h1>Monitoring Infra</h1>

# Table of Contents

<!-- TOC START min:1 max:2 link:true asterisk:false update:true -->
- [Table of Contents](#table-of-contents)
- [Set up Grafana and Prometheus](#set-up-grafana-and-prometheus)
  - [Configure Prometheus.yml](#configure-prometheusyml)
  - [Update docker-compose.yml](#update-docker-composeyml)
  - [Test it out](#test-it-out)
- [Configure Nginx](#configure-nginx)
- [Create the Grafana dashboards](#create-the-grafana-dashboards)
  - [Add Data Sources](#add-data-sources)
  - [Add Dashboards](#add-dashboards)
- [Final testing](#final-testing)
- [Next Steps](#next-steps)
<!-- TOC END -->


# Set up Grafana and Prometheus

## Configure Prometheus.yml

For Prometheus to know where to scrape data from, we need to know the Docker bride IP. First determine the ID for any `graph-node` container, and then use this command to get the bridge IP.

```bash
docker ps
# My Container ID is "5bd...", yours will be different

docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' <container-ID>
> 172.17.0.1
```

Now we will update our `prometheus.yml` file which tells Prometheus where to scrape data from.

```bash
cd ~/indexer-docker-compose/monitoring
nano prometheus.yml
```

In our case our bridge IP is `172.17.0.1`, so replace this with yours

```yaml
# ...
scrape_configs:
  - job_name: "thegraph"
    static_configs:
      - targets:
          - 172.17.0.1:8140 # CHANGE ME
          - 172.17.0.1:8040 # CHANGE ME
```

Things to pay attention to:

- Each graph-node exposes metrics for only its own operation. Thus, we need to scrape both the "query-node" `8040` and "index-node" `8140`

## Update docker-compose.yml

Now we need to update the `docker-compose.yml` with our Grafana server name and password.

```bash
nano docker-compose.yml
```

```yaml
services:
  grafana:
    image: grafana/grafana:6.4.4
    # ...
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin # CHANGE ME
      GF_SERVER_DOMAIN: "grafana.mysite.com" # CHANGE ME
      GF_SERVER_ROOT_URL: "https://grafana.mysite.com" # CHANGE ME
```

Finally we create the folder to store Prometheus data, and set the approriate permissions

```bash
# Prometheus
mkdir ~/monitoring-data
mkdir ~/monitoring-data/prometheus
sudo chown 65534:65534 $HOME/monitoring-data/prometheus

# Grafana
sudo chown 472:472 -R /docker/volumes
```

Now we can start running our monitoring services.

```bash
docker-compose up -d
```

## Test it out

From your local machine, you can try to create a tunnel to port `3000` to see the Grafana dashboard

```bash
ssh -L 127.0.0.1:8000:127.0.0.1:3000 user@mysite.com
```

Test that you can see the Prometheus UI as well.

```bash
ssh -L 127.0.0.1:8000:127.0.0.1:9090 user@mysite.com
```

# Configure Nginx

Next we need to permanently expose port `3000` to the world, so let's add a new server file `monitoring.conf` from the `/nginx` folder of this repo. You will need to update the `server_name`.

```bash
sudo cp ~/indexer-docker-compose/nginx/monitoring.conf /etc/nginx/sites-enabled

nano /etc/nginx/sites-enabled/monitoring.conf
# Update server_name
```

Let's put the changes into effect:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

Now we need Certbot to issue a certificate. All subdomains (grafana, prometheus, indexer) should get a certificate.

```bash
sudo certbot --nginx certonly
sudo systemctl reload nginx
```

You should now be able to access your Grafana at `grafana.mysite.com`

# Create the Grafana dashboards

## Add Data Sources

We will use the Docker bridge IP again for this step, so that Grafana can access Prometheus.

Navigate to `grafana.mysite.com/datasources`, and use the green button "Add data source" to add a new source.

### Postgres

1. Optional, but recommended: Create a new postgres user with limited permissions. (You may need to stop your graph nodes first)

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

### Prometheus

Should be named (lowercase) "prometheus". URL will look like `172.17.0.1:9090`

## Add Dashboards

Navigate to `grafana.mysite.com/dashboards`, and use the grey "Import" button to create a new dashboard.

Create a new dashboard using each of the following JSON files:

- [indexing.json](./dashboards/indexing.json)
- [metrics.json](./dashboards/metrics.json)
- [postgres.json](./dashboards/postgres.json)

# Final testing

Let's check that our Prometheus endpoint is properly exposed. Update with your domain and paste into your browser:

prometheus.mysite.com/federate?match[]=subgraph_query_execution_time_count&match[]=subgraph_count&match[]=QmXKwSEMirgWVn41nRzkT3hpUBw29cp619Gx58XW6mPhZP_sync_total_secs&match[]=Qme2hDXrkBpuXAYEuwGPAjr6zwiMZV4FHLLBa3BHzatBWx_sync_total_secs&match[]=QmTXzATwNfgGVukV1fX2T6xw9f6LAYRVWpsdXyRWzUR2H9_sync_total_secs

You should get a response like

```
# TYPE QmTXzATwNfgGVukV1fX2T6xw9f6LAYRVWpsdXyRWzUR2H9_sync_total_secs untyped
QmTXzATwNfgGVukV1fX2T6xw9f6LAYRVWpsdXyRWzUR2H9_sync_total_secs{instance="172.17.0.1:8040",job="thegraph-indexer"} 0 1597782701051
...
```

# Next Steps

🥳 Wow, look how far you made it! You tackled some very impressive problems today. You are an incredible person, and deserve a special treat! Congrats on completing Phase 0. Here we come Phase 1
