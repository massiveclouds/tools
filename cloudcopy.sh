#!/bin/bash
# Massive Clouds Copyright 2013
# Written by Christopher Mera
# chris@massiveclouds.com

# Parameters for authentication to the Storage Repository
export AWS_ACCESS_KEY_ID="***REMOVED***"
export AWS_SECRET_ACCESS_KEY="***REMOVED***"

# Parameters for the Backup
# 
# FULL_INTERVAL - How often to run a Full Backup
# KEEP_FULLS - The Period of Time You want to Keep Full Backups
# BUCKET_NAME - The bucket created on AWS S3 where this script will dump data.
# SRC - The path of where duplicity will read files to backup to S3 from.

FULL_INTERVAL="1W"
KEEP_FULLS="2W"
BUCKET_NAME='***REMOVED***'
YEAR=$(date +%Y)
#SRC="/tmp/source"
SRC="/var/www/httpdocs"
EXCLIST=( "/var/www/httpdocs/media/catalog/product" \
	 "/var/www/httpdocs/var/backup/" \
	 "/var/www/httpdocs/var/cache/" \
	"/var/www/httpdocs/var/session/" \
	)
###### DO NOT EDIT BELOW THIS LINE #######
###### DO NOT EDIT BELOW THIS LINE #######
###### DO NOT EDIT BELOW THIS LINE #######
###### DO NOT EDIT BELOW THIS LINE #######

for exclude in ${EXCLIST[@]}
	do
	TMP=" --exclude "$exclude
	EXCLUDE=$EXCLUDE$TMP
done

# Breakup the Volumes to 200MB chunks, upload like crazy. Keep requests low.
PARAMS="--no-encryption --volsize 200 -vinfo --asynchronous-upload --full-if-older-than ${FULL_INTERVAL}"
DEST="s3+http://${BUCKET_NAME}"


###### JUST SOME LOGIC AND MORE ######
function fullbackup() 
{
	# Simple test to make sure we arent running this more than once.
	[ `ps axu | grep -v "grep" | grep --count "duplicity"` -gt 0 ] && exit 1
	duplicity $PARAMS $EXCLUDE $SRC $DEST
}

# Restore data and shit
function usage()
{
	echo "Whoa and shit"
}

function restorelast() 
{
	duplicity --no-encryption ${DEST} /tmp/restored-files
}

	# Retain Data for a Rolling 60 Days, Save Space and Money.
function purge() 
{
	duplicity remove-older-than ${KEEP_FULLS} --force --extra-clean $PARAMS $DEST
}

	# Clean shit up, what? I'm not sure what yet.
function clean() 
{
	duplicity cleanup --force $PARAMS $DEST
	unset PASSPHRASE
	unset AWS_ACCESS_KEY_ID
	unset AWS_SECRET_ACCESS_KEY
}

# Process is to upload data to cloud, clean up any old data at the time of upload, and then clean up after myself.

[[ -z "$*" ]] && COMMAND=broken || COMMAND=$1
	
case "$COMMAND" in
	"backup")
		fullbackup
		purge
		clean
		exit
	;;
	
	"restore")
		restorelast
		clean
		exit
	;;
	
	*)
		usage
	;;
esac


		
