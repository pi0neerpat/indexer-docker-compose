# Indexer Nginx Configurations

After placing these in `etc/nginx/sites-enabled`, you should use Certbot to create certificates for **all sites**.

# Help I've never used Nginx!

## Installation

Adapted from [Digital Ocean - Installation on Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04#step-2-%E2%80%93-adjusting-the-firewall)

```bash
sudo apt update
sudo apt install nginx

sudo ufw app list
#  Nginx Full
#  Nginx HTTP <- Choose this one while SSL is not be enabled
#  Nginx HTTPS <- Switch to this one later
sudo ufw allow 'Nginx HTTP'

# Confirm things are running
sudo ufw status
systemctl status nginx

# Enable restart on reboot
sudo systemctl enable nginx
```

## Configuration

To configure Nginx a `.conf` file is added to `/etc/nginx/sites-enabled` which tells Nginx how to handle incoming requests.

Since we will be serving existing ports on our machine (instead of static sites), we will be using the [reverse-proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/) feature. Here is an example `.conf` file which allows anyone to access port `8000` on our server at `http://indexer.mysite.com/`

```js
server {
    server_name indexer.mysite.com;

    location / {
        proxy_pass http://localhost:8000;
        # ...
    }
}
```

After you make a change to a `.conf` file, you can test it and apply it using these commands:

```bash
# Check the config files are OK
sudo nginx -t

# Restart the service the the new configs
sudo systemctl reload nginx
```

That's pretty much it. You can do it!
