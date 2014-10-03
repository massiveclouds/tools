#!/bin/bash
#
# code base deployment from svn repository to live site
#

# set up variables / configuration
ADMIN_EMAILS="support@massiveclouds.com"
HEADER="From: Cloud Deploy Bot <no-reply@***REMOVED***>"
# /srv/htdocs or /var/www ?
WEB_BASE="/var/www"
# PATH where new repo can be found
SYNC_FROM="/home/developer/current"
# URL as used in Nginx host defines
DOMAIN=""

DATE=$(date +%m%d%Y)
REVISION=$(cat ${CODEPATH}/.revision)
FAKE_DOCROOT="${WEB_BASE}/${DOMAIN}/public_html"
REAL_DOCROOT="${WEB_BASE}/${DOMAIN}/current${REVISION}"

ERRORMSG=""
LOGFILE="/tmp/${DOMAIN}_${DATE}_${REVISION}.log"

# pretty print
function pprint() {
	echo \<=== $*
}

# copy current $FAKE_ROOT code to new $REAL_DOCROOT
# where $REVISION is a new version
# rsync the new copy with changes from $SYNC_FROM
function magento_copy_current() {
	pprint "Performing upgrade to codebase with new revision"
	pprint "Logging file updates to ${LOGFILE}"
	cp -Lrp $FAKE_DOCROOT $REAL_DOCROOT
	rsync -avpz ${SYNC_FROM}/ ${REAL_DOCROOT} 2>&1 >> ${LOGFILE}
}

# magento optimization steps
# compress js files
function magento_compress_js() {
	pprint "Compressing js libraries files"
	cd $FAKE_DOCROOT
	node skin/frontend/enterprise/annefontaine/js/r.js -o skin/frontend/enterprise/annefontaine/js/build.js
	sed -e "s,<file>js/main.js</file>,<file>build/min.js</file>," -i $FAKE_DOCROOT/app/design/frontend/enterprise/annefontaine/layout/local.xml
}

# stage the new changes locally by removing old cache
function magento_remove_cache() {
	pprint "Removing cache from $FAKE_DOCROOT"
 	rm -rf $CURRENTCODE/var/cache $CURRENTCODE/var/full_page_cache
}

# the new copy created in $REAL_DOCROOT is pointed to by $FAKE_DOCROOT
function update_link() {
	pprint "Updating symlink for web services for $FAKE_DOCROOT -> $REAL_DOCROOT"
	rm -rf $FAKE_DOCROOT
	ln -sf $REAL_DOCROOT $FAKE_DOCROOT
}


# restart php5-fpm to throw away APC cache and start over
function flush_php() {
	pprint "Flushing php5-fpm APC cache"
	sudo service php5-fpm restart
}

# deliver a state message whether success or failure
function notify_users() {
	pprint "Emailing ${ADMIN_EMAILS}"
	printf "$*" | mail -a "$HEADER" -s "Deployment of Revision ${REVISION} Status (automatic-deploy)" ${ADMIN_EMAILS}  
}

# Before we do any work, lets make sure we can do it safely
# * run as www-data user only, ensure webserver permissions stay intact
# - ensure no existing deploy process is running, if so exit
# - if exit without success, clean up the mess
curuser=$(whoami)
if [ "$curuser" != "www-data" ]; then
        pprint "Must run as www-data user!"
	else
	if pgrep $(basename $0) then
		pprint "Found a running job, failing.."
		exit
		else
		currev=$(cat $FAKE_DOCROOT/.revision)
			if [ "$REVISION" -gt "$currev" ]; then
			pprint "Found new changes in $SYNC_FROM"
			pprint "Upgrading revision $currev to $REVISION"
			magento_copy_current
			magento_compress_js
			magento_remove_cache
			update_link
			flush_php
			notify_users "This deployment was successful, $currev was updated to $REVISION.\nLog Output:\n$(/bin/cat $LOGFILE)"
			exit
				else
				ERRORMSG="The current revision of ${currev} matches the code found in ${SYNC_FROM}"
			fi
	fi
fi

# If we got here, it failed
pprint "Deploy script exited due to an error, and nothing was deployed."
notify_users "Deploy exited due to an error, and nothing was deployed. \n${ERRORMSG}"
