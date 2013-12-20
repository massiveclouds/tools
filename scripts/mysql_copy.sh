#!/bin/bash
TMPFILE="/tmp/innobackupex-pid.$$.tmp"
CREDS="--user=msandbox --password=msandbox"
PORT="--port=5529"
SOCKET="--socket=/tmp/mysql_sandbox5529.sock"
DEFAULTS="--defaults-file=/root/sandboxes/msb_5_5_29/my.sandbox.cnf"
FILTERTABLES="--include=.*[.].*"
PARALLEL="--parallel=10"
BACKUPDIR=/root/backup
INNOBACKUPEX=/usr/bin/innobackupex
IBBACKUP="--ibbackup=xtrabackup_55"
BASEBACKDIR=$BACKUPDIR/base
INCRBACKDIR=$BACKUPDIR/incr
LOGFILE=/var/log/innobackup.log
FULLBACKUPRET=3600 #604800 # How long to keep incrementing a backup for, minimum 60
KEEP=1 # Keep this number of backups, appart form the one currently being incremented
DATE="`/bin/date +%Y%m%d-%H%M%S`"
TYPE=full
FILE="${TYPE}_${DATE}.sql"
START=`date +%s`
TAR=/bin/tar
GZIP=/bin/gzip

## Check if mysql running

if [ -z "`mysqladmin $CREDS $PORT $SOCKET status | grep 'Uptime'`" ]
then
  echo "HALTED: MySQL does not appear to be running."; echo
  exit 1
fi

## Check all above directories and locations valid 
## ...

create_full(){

# Create a new full backup
#  echo "$INNOBACKUPEX $DEFAULTS $CREDS $PORT $SOCKET $IBBACKUP $PARALLEL --stream=tar ./ | gzip - > $BASEBACKDIR/$FILE.gz " 
#Uncompressed
  $INNOBACKUPEX $DEFAULTS $CREDS $PORT $SOCKET $IBBACKUP $PARALLEL  $BASEBACKDIR  
#Compressed
  $INNOBACKUPEX $DEFAULTS $CREDS $PORT $SOCKET $IBBACKUP $PARALLEL --stream=tar ./ | gzip - > $BASEBACKDIR/$FILE.gz 
}

#Creating Full Backup
create_full
exit $?
