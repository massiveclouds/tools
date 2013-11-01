#!/bin/bash
FC_ROOT="/opt/massive"
FC_DATADIR="${FC_ROOT}/Backups/files"
FC_SOURCE=$1
date=`date "+%Y-%m-%dT%H:%M:%S"`

function fc_post_processing {
	echo "* Updating 'current' link -> back-${date}"
	rm -f ${FC_DATADIR}/current
	ln -s back-$date ${FC_DATADIR}/current
	exit 0;
}

function fc_create_starting_point {
	echo "* Creating $FC_DATADIR "
	mkdir -p ${FC_DATADIR}
	echo "* Creating first full backup "	
	rsync -a ${FC_SOURCE} ${FC_DATADIR}/back-$date
	fc_post_processing
}

function fc_create_new_point {
	echo "* Creating new restore point"
	rsync -a --link-dest=${FC_DATADIR}/current ${FC_SOURCE} ${FC_DATADIR}/back-$date
	fc_post_processing
}

# if no argument provided, do nothing
[ -z ${FC_SOURCE} ] || echo "* No source provided" && exit 1;

# if directory exists then continue otherwise exit
[ -d ${FC_SOURCE} ]  || echo "* Source doesn't exist" && exit 1;

# if 'Backups/files' directory doesnt exist, safe to assume no starting point
[ ! -d ${FC_DATADIR} ] && fc_create_starting_point

# if 'Backups/files/current' link exists, create a new restore point
[ -d ${FC_DATADIR}/current ] && fc_create_new_point