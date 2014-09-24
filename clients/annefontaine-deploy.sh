#!/bin/bash
#
# code base deployment from svn repository to live site
#

# set up variables / configuration
CODEPATH="/home/developer/current"
DOMAIN="***REMOVED***"
CURRENTCODE="/var/www/${DOMAIN}/public_html"
REVISION=$(cat ${CODEPATH}/.revision)
DOCROOT="/var/www/${DOMAIN}/current${REVISION}"
DATE=$(date +%m%d%Y)

# pretty print
function pprint() {
	echo \<=== $*
}

# compress js files
function magento_compress_js() {
	pprint "Compressing js libraries files"
	cd $CURRENTCODE
	node skin/frontend/enterprise/annefontaine/js/r.js -o skin/frontend/enterprise/annefontaine/js/build.js
	sed -e "s,<file>js/main.js</file>,<file>build/min.js</file>," -i $CURRENTCODE/app/design/frontend/enterprise/annefontaine/layout/local.xml
}

# remove cache
function magento_remove_cache() {
	pprint "Removing cache from $CURRENTCODE"
 rm -rf $CURRENTCODE/var/session $CURRENTCODE/var/cache $CURRENTCODE/var/full_page_cache
}

# copy new existing codebase to /var/www/$DOMAIN/current$REVISION
# then rsync with new uploaded version
function magento_copy_current() {
	pprint "Performing upgrade to codebase with new revision"
	pprint "Logging file updates to /tmp/deploy-rsync-$DATE-$REVISION.log"
 cp -Lrp $CURRENTCODE $DOCROOT
 rsync -avpz $CODEPATH/ $DOCROOT 2>&1 >> /tmp/deploy-rsync-$DATE-$REVISION.log
}


# update symbolic link for nginx configuration
function update_link() {
	pprint "Updating symlink for nginx for $DOCROOT"
 rm -rf $CURRENTCODE
 ln -sf $DOCROOT $CURRENTCODE
}

function flush_php() {
# restart php5-fpm
	pprint "Flushing php5-fpm apc cache"
 sudo service php5-fpm restart
}


# main logic
curuser=$(whoami)
if [ "$curuser" != "www-data" ]; then
        pprint "Must run as www-data user!"
else 
	currev=$(cat $CURRENTCODE/.revision)
	if [ "$currev" -lt "$REVISION" ]; then
	pprint "Upgrading revision $currev to $REVISION"
	magento_copy_current
	magento_compress_js
	magento_remove_cache
	update_link
	flush_php
	fi
fi
pprint "Deploy script exited"
