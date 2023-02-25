#!/bin/bash

# Set variables
BACKUP_DIR="/mnt/backup"
JENKINS_HOME="/var/lib/jenkins"
BACKUP_FILE="jenkins_backup_$(date +%Y%m%d%H%M%S).tar.gz"

# Create backup directory if it doesn't exist
if [ ! -d $BACKUP_DIR ]; then
  sudo mkdir -p $BACKUP_DIR && cd $BACKUP_DIR
fi

# Create backup of Jenkins home directory
cd $BACKUP_DIR && sudo tar -zcvf $BACKUP_FILE $JENKINS_HOME
echo "backup completed"

# Set permissions to restrict access to backup file
sudo chmod 600 $BACKUP_DIR/*

# Delete backups older than 7 days
find $BACKUP_DIR -type f -mtime +7 -delete
