# Provisioning new servers

## Basic setup

login as root

```bash
# reset the root password
sudo passwd root

adduser myself
usermod -aG sudo myself

ufw app list
ufw allow OpenSSH
ufw enable

dpkg-reconfigure -plow unattended-upgrades

exit
```

Login with your new user and install npm using nvm

```bash
curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh -o install_nvm.sh
bash install_nvm.sh
source ~/.profile
nvm install --lts
nvm use --lts
```

Install docker using [these instructions](https://docs.docker.com/engine/install/ubuntu/). Alternatively use the official convenience scripts.

```bash
# Download Docker
curl -fsSL get.docker.com -o get-docker.sh
# Install Docker using the stable channel (instead of the default "edge")
CHANNEL=stable sh get-docker.sh
# Remove Docker install script
rm get-docker.sh

# Remove need for sudo
sudo groupadd docker
sudo usermod -aG docker $USER
# logout or restart the VM to take effect
```

If you're migrating from an existing server, don't forget the `-P` option on `rsync`

```bash
rsync -P A host:B
```

See [Copy PostgreSQL database between computers](https://wiki-bsse.ethz.ch/display/ITDOC/Copy+PostgreSQL+database+between+computers)
