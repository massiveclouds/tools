#!/bin/sh
# This will add repositories for Ubuntu 12.04 LTS
# Installation of Percona Xtrabackup tool
# Install of Python Boto Libraries
# Install of duplicity
#
#
# Requirements

CONF_DIR="/etc/massive"
BIN_DIR="/usr/local/bin"
do_first_run () {
echo 'deb http://repo.percona.com/apt precise main' >> /etc/apt/sources.list.d/percona.list
echo 'deb-src http://repo.percona.com/apt precise main' >> /etc/apt/sources.list.d/percona.list
# Sync up
apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
apt-get update

# apt-get -y upgrade

# Install the binaries
apt-get -y install duplicity python-boto percona-xtrabackup

# Setup directory structure
mkdir -p $CONF_DIR
cp ./sync.conf $CONF_DIR/sync.conf
echo "Install completed"
exit 0
}

[ -f /etc/apt/sources.list.d/percona.list ] || do_first_run 
echo "Already installed"
echo
exit 1

