#!/bin/bash
# Massive Clouds Copyright 2013
# Written by Christopher Mera
# chris@massiveclouds.com
# TODO: Move configuration to config file, /opt/massive/etc/?
source /etc/massive/sync.conf

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


		
