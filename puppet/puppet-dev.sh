#!/bin/bash
# update operating system

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

# puppet labs repo
wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
dpkg -i puppetlabs-release-precise.deb 

# update for sanity, then install and stop service
apt-get update
apt-get install -y puppet
service puppet stop

# remove ssl because we're going to mess with hostnames
rm -rf /var/lib/puppet/ssl

# setup hostname
hostname $(uname -n)

# hosts setup 
grep puppet || cat >> /etc/hosts <<-EOF 
$(/usr/bin/host puppet.d.mmi-nyc.com  | head -1 | /usr/bin/awk '{print $4}') puppet
EOF

# puppet configuration
grep development /etc/puppet/puppet.conf || cat >> /etc/puppet/puppet.conf <<-EOF
[agent]
server = puppet.d.mmi-nyc.com
environment = development
EOF

PUPPET=`which puppet`

[[ -z "$PUPPET" ]] && echo its empty

