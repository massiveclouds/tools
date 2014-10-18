#!/bin/bash
# Massive Clouds Copyright 2013
# Written by Christopher Mera
# chris@massiveclouds.com
# 
# TODO: Exclusion lists
# TODO: Move configuration variables to external config file, /opt/massive/etc/?
source /etc/massive/sync.conf
date=`date "+%Y-%m-%dT%H:%M:%S"`

fc_update_link () {
	echo "* Updating 'current' link -> back-${date}"
	rm -f ${FC_DATADIR}/current
	ln -s back-$date ${FC_DATADIR}/current
	exit 0;
}

fc_create_current_point () {
	echo "* Preparing to add data to $FC_DATADIR "
	mkdir -p ${FC_DATADIR}
	echo "* Performing backup saved to $FC_DATADIR"	
	rsync -a ${FC_SOURCE} ${FC_DATADIR}/back-$date
	fc_update_link
}

fc_delete_current_point () {
	echo "* Removing stale data"
	rm -rf ${FC_DATADIR}
	fc_create_current_point
}

# if no argument provided, do nothing
# [ -z ${FC_SOURCE} ] && usage 

# if directory exists then continue otherwise exit
[ -d ${FC_SOURCE} ]  || echo "Source Directory doesn't exist"

# if 'Backups/files' directory doesnt exist, safe to assume no starting point
[ -d ${FC_DATADIR} ] ||  fc_create_current_point

# if 'Backups/files/current' link exists, create a new restore point
[ -d ${FC_DATADIR}/current ] && fc_delete_current_point
