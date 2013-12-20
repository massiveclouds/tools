#!/bin/bash
# Massive Clouds Copyright 2013
# Written by Christopher Mera
# chris@massiveclouds.com
# TODO: Move configuration to config file, /opt/massive/etc/?

export CC_SOURCE="/opt/massive/Backups/files/current"

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
###### DO NOT EDIT BELOW THIS LINE #######
###### DO NOT EDIT BELOW THIS LINE #######
###### DO NOT EDIT BELOW THIS LINE #######
###### DO NOT EDIT BELOW THIS LINE #######

# Breakup the Volumes to 200MB chunks, upload like crazy. Keep requests low.
PARAMS="--no-encryption --volsize 200 -vinfo --asynchronous-upload --full-if-older-than ${FULL_INTERVAL}"
DEST="s3+http://${BUCKET_NAME}"


###### JUST SOME LOGIC AND MORE ######
function fullbackup() 
{
	# Simple test to make sure we arent running this more than once.
	[ `ps axu | grep -v "grep" | grep --count "duplicity"` -gt 0 ] && exit 1
	duplicity $PARAMS $SRC $DEST
}

# Restore data and shit
function usage()
{
	echo "There was an unspecified error."
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


		
