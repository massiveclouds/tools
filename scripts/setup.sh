#!/bin/sh
# This will add repositories for Ubuntu 12.04 LTS
# Installation of Percona Xtrabackup tool
# Install of Python Boto Libraries
# Install of duplicity
#
#
# Requirements
echo 'deb http://repo.percona.com/apt precise main' >> /etc/apt/sources.list
echo 'deb-src http://repo.percona.com/apt precise main' >> /etc/apt/sources.list


# Sync up
apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
apt-get update
# apt-get -y upgrade

# Install the binaries
apt-get -y install duplicity python-boto percona-xtrabackup

