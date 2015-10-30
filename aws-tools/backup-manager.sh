#!/bin/bash
# Massive Clouds
# 2015 (C) All Rights Reserved 
#
# This is provided as-is with no warranty or support.
# Please contact support@massiveclouds.com with suggestions or comments.

# Directory definitions for config files and logs. 
# Note: Both can be overwritten from environment configuration file
top_dir=$HOME/aws-tools
log_dir=$HOME/aws-logs
name_string="My EC2 Instance" 
log_filename="backup-manager.log"
bin_path="/usr/local/bin"


function pprint() {
	echo "** $*"
	echo "$*" >> $log_dir/$log_filename
}
# Looping through environments
for f in $(ls $top_dir | grep -i ".*\.env$"); do
	# Setting default values
	aws_config="undef";
	instance_list="undef";
	data_retention=7;
	
	pprint `date`
	pprint "Found environment configuration file -> $f" 
	. $top_dir/$f;

	# Error checking for missing variable declaration in environment config file
	if [[ $aws_config =~ ^undef || $instance_list =~ ^undef ]]; then
		pprint "Configuration error in $f, skipping environment..." 
	else
		pprint "Exporting $aws_config"
	 	export AWS_CONFIG_FILE=$aws_config 
		$bin_path/aws ec2 describe-regions 2>&1
		if [ $? -eq 0 ]; then
			pprint "Starting AMI backup..."
			pprint "Looking for instances in $instance_list" 
			# Part 1 - Backup
			while read line; do
				if [[ $line =~ ^# ]]; then continue;
				elif [[ $line =~ ^(.+)$ ]]; then
					instance=${BASH_REMATCH[1]}
					aminame="`date +%Y%m%d` $name_string"
					pprint "Found $instance, using name $aminame"
					$bin_path/aws ec2 create-image --instance-id $instance --name "$aminame" --description "BackupManager auto AMI creation" | grep -i ami | awk '{gsub(/"/, "", $2); print $2 " created sucessfully!" }' >> $log_dir/$log_filename
				fi
			done < $instance_list

			# Part 2 - Cleanup
			# Find all our auto AMIs based on Description, save list to temp file
		        pprint "Starting AMI cleanup..."
			age=`date +"%y%m%d" --date "$data_retention days ago"`;
			$bin_path/aws ec2 describe-images --owners self --filters "Name=description,Values=BackupManager auto AMI creation" --output text --query 'Images[*].[ImageId, State, CreationDate]' > /tmp/amidel.txt;

	  		cat /tmp/amidel.txt | while IFS=$'\t' read imageid state creationdate; do
				if [[ $state =~ "available" ]]; then
					stamp=$(echo $creationdate | cut -f1 -dT)
					cond=$(date -d $stamp +"%y%m%d")
					# Are the files old enough?
					if [ $age -ge $cond ]; then
						pprint "Found AMI older then $data_retention days, ImageID: $imageid. Deregistering..." 
						$bin_path/aws ec2 describe-images --image-ids $imageid | grep snap | awk '{gsub(/",/, "", $2); gsub(/"/, "", $2); print $2}' > /tmp/snap.txt
			        		$bin_path/aws ec2 deregister-image --image-id $imageid
						pprint "Deleting associated snapshots..."
			        		pprint `cat /tmp/snap.txt`
			   	    	 	for i in `cat /tmp/snap.txt`; do $bin_path/aws ec2 delete-snapshot --snapshot-id $i ; done
					fi
				fi
			done
		else
			pprint "Authentication error - check your AWS credentials! Skipping environment..." 
		fi
	fi
done
pprint "All done!"
