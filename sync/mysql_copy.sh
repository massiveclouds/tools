#!/bin/bash
# Massive Clouds Copyright 2013
# Written by Christopher Mera
# chris@massiveclouds.com
#
#

source /etc/massive/sync.conf
DATE="`/bin/date +%Y%m%d-%H%M%S`"
TYPE=full
FILE="${TYPE}_${DATE}.sql"
START=`date +%s`
TAR=/bin/tar
GZIP=/bin/gzip

db_update_link () {
	echo "* Updating 'current' link -> $BASEBACKDIR"
	rm -rf ${BASEBACKDIR}/current
	exit 0;
}
db_create_current_point () {
	echo "* Creating $BASEBACKDIR"
	mkdir -p ${BASEBACKDIR}
	$INNOBACKUPEX $CREDS $PORT $PARALLEL $BASEBACKDIR  
}

db_delete_current_point() {
	echo "* Removing stale data"
	rm -rf ${BACKBACKDIR}
	db_create_current_point
}

## Check if mysql running

if [ -z "`mysqladmin $CREDS status | grep 'Uptime'`" ]
then
  echo "HALTED: MySQL does not appear to be running."; echo
  exit 1
fi

#Create Full Backup

[ -d ${BASEBACKDIR} ] ||  db_create_current_point

[ -d ${BACKBACKDIR} ] && db_delete_current_point
