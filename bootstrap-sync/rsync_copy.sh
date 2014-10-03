#!/bin/bash
# Massive Clouds Copyright 2013
# Written by Christopher Mera
# chris@massiveclouds.com
# 
# TODO: Exclusion lists
# TODO: Move configuration variables to external config file, /opt/massive/etc/?
source /etc/massive/sync.conf
FC=`basename $0`
date=`date "+%Y-%m-%dT%H:%M:%S"`

fc_post_processing () {
	echo "* Updating 'current' link -> back-${date}"
	rm -f ${FC_DATADIR}/current
	ln -s back-$date ${FC_DATADIR}/current
	exit 0;
}

fc_create_starting_point () {
	echo "* Creating $FC_DATADIR "
	mkdir -p ${FC_DATADIR}
	echo "* Creating first full backup "	
	rsync -a ${FC_SOURCE} ${FC_DATADIR}/back-$date
	fc_post_processing
}

fc_create_new_point () {
	echo "* Creating new restore point"
	rsync -a --link-dest=${FC_DATADIR}/current ${FC_SOURCE} ${FC_DATADIR}/back-$date
	fc_post_processing
}

usage() {
	printf "Invalid arguments!\n"
	printf "\t$FC: <directory to backup>"
	printf "\n"
	exit;
}

# if no argument provided, do nothing
# [ -z ${FC_SOURCE} ] && usage 

# if directory exists then continue otherwise exit
[ -d ${FC_SOURCE} ]  || echo "Source Directory doesn't exist"

# if 'Backups/files' directory doesnt exist, safe to assume no starting point
[ -d ${FC_DATADIR} ] ||  fc_create_starting_point

# if 'Backups/files/current' link exists, create a new restore point
[ -d ${FC_DATADIR}/current ] && fc_create_new_point
