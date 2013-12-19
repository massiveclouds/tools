#!/bin/bash
# update operating system
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y upgrade

# puppet labs repo
#wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
#dpkg -i puppetlabs-release-precise.deb 

# update for sanity, then install and stop service
apt-get update
apt-get install -y puppet
service puppet stop

# remove ssl because we're going to mess with hostnames
rm -rf /var/lib/puppet/ssl

# setup hostname
hostname $(uname -n)

# hosts setup 
cat >> /etc/hosts <<-EOF
echo $(/usr/bin/host mmaster01.d.mmi-nyc.com  | head -1 | /usr/bin/awk '{print $4}') mmaster01
EOF

# puppet configuration
cat >> /etc/puppet/puppet.conf <<-EOF
[agent]
server = mmaster01.d.mmi-nyc.com 
EOF

# puppet cron to pull catalogs
cat > /tmp/puppet-cron <<-EOF
SHELL=/bin/bash
*/3 * * * * /usr/bin/puppet agent --server=mmaster01 --environment=production
EOF

/usr/bin/crontab /tmp/puppet-cron && /bin/rm /tmp/puppet-cron

# configure puppet service 
# we use cron for now
cat > /etc/default/puppet <<-EOF
# Defaults for puppet - sourced by /etc/init.d/puppet
# Start puppet on boot?
START=no
# Startup options
DAEMON_OPTS=""
EOF
# Clean up
export DEBIAN_FRONTEND=dialog

# catch bootstrap clients
if [[ "$(uname -n)" == *"bootstrap"* ]]; then 
	exit 0
fi

if [[ "$(uname -n)" == *"master"* ]]; then
	exit 0
fi
sed -i -e 's|^.*massive.*$|#\0|' /etc/rc.local
exit 0
