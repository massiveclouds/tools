#!/bin/sh
#
#
#

# Requirements
echo 'deb http://repo.percona.com/apt precise main' >> /etc/apt/sources.list
echo 'deb-src http://repo.percona.com/apt precise main' >> /etc/apt/sources.list
apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A

# Sync up
apt-get update && apt-get -y upgrade

# Packages
apt-get -y install duplicity python-boto percona-xtrabackup

