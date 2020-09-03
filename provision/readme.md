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

Install docker using [these instructions](https://docs.docker.com/engine/install/ubuntu/)


If you're migrating from an existing server, don't forget the `-P ` option on `rsync`

```bash
rsync -P A host:B
```

See [Copy PostgreSQL database between computers](https://wiki-bsse.ethz.ch/display/ITDOC/Copy+PostgreSQL+database+between+computers)
