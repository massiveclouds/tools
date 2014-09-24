#!/bin/bash
source /etc/massive/config/config

DATE="`/bin/date +%Y%m%d-%H%M%S`"
TYPE=full
FILE="${TYPE}_${DATE}.sql"
START=`date +%s`
TAR=/bin/tar
GZIP=/bin/gzip

## Check if mysql running

if [ -z "`mysqladmin $CREDS status | grep 'Uptime'`" ]
then
  echo "HALTED: MySQL does not appear to be running."; echo
  exit 1
fi

## Check all above directories and locations valid 
## ...

db_create_full () {

# Create a new full backup
#  echo "$INNOBACKUPEX $DEFAULTS $CREDS $PORT $SOCKET $IBBACKUP $PARALLEL --stream=tar ./ | gzip - > $BASEBACKDIR/$FILE.gz " 
#Uncompressed
#  $INNOBACKUPEX $CREDS $PORT $PARALLEL $BASEBACKDIR  
#Compressed
  $INNOBACKUPEX $CREDS $PORT $PARALLEL --stream=tar ./ | gzip - > $BASEBACKDIR/$FILE.gz 
}

#Create Full Backup
db_create_full
exit $?
