#!/bin/sh
FC_ROOT="/opt/massive"
FC_DATADIR="${ROOT}/Backups/files"
FC_SOURCE=$1

date=`date "+%Y-%m-%dT%H:%M:%S"`
rsync -aP --link-dest=${FC_DATADIR}/current ${FC_SOURCE} ${FC_DATADIR}/back-$date
rm -f ${FC_DATADIR}/current
ln -s back-$date ${FC_DATADIR}/current