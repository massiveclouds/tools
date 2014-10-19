OVERVIEW

	armada:
	configure a node to join massive clouds armada's confmgr services
		- simple puppet bootstrap

	sync:
	basic tools to configure a node to replicate data to cloud block storage (s3 currently)

	apphelpers:
	applications we've worked with and processes we follow
		- magento enterprise

TODO

	armada:
	pull data from armada web services for proper puppet host
	
	sync
	clean up configuration file
	improve innobackupex wrapper script (mysql_copy)
	find a replacement for duplicity (s3_copy)
	
	apphelpers:
	generalize the script to support a wider array of configurations
	introduce options to better support one-off configurations

