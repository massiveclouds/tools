#!/bin/bash
# update operating system
CONF_MGR="puppet.d.mmi-nyc.com"
RELEASE=$(lsb_release -c | cut -f2)

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

# puppet labs repo
wget http://apt.puppetlabs.com/puppetlabs-release-$RELEASE.deb
dpkg -i puppetlabs-release-$RELEASE.deb

# update for sanity, then install and stop service
apt-get update
apt-get install -y puppet
service puppet stop

# remove ssl because we're going to mess with hostnames
rm -rf /var/lib/puppet/ssl

# setup hostname
hostname $(uname -n)

# puppet configuration
grep development /etc/puppet/puppet.conf || cat >> /etc/puppet/puppet.conf <<-EOF
[agent]
server = ${CONF_MGR}
environment = development
EOF

# Enable the puppet client
sed -i /etc/default/puppet -e 's/START=no/START=yes/'

# start puppet at last
service puppet start

