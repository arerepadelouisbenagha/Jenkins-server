#!/bin/bash

# AWS region and volume ID
AWS_REGION="us-east-1"
VOLUME_ID="vol-0c83739593272ca68"

# Backup frequency and retention period (in days)
BACKUP_DAYS=(1 4) # Backup on Mondays and Thursdays
RETENTION_DAYS=30

# AWS CLI command to create a snapshot
aws ec2 create-snapshot \
  --region $AWS_REGION \
  --volume-id $VOLUME_ID \
  --description "EBS snapshot $(date +'%Y-%m-%d %H:%M:%S')" \
  --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value=dev},{Key=Owner,Value=TSR(Tech Starter Republic)},{Key=Managedwith,Value=ShellScripts)}]' \
  

# AWS CLI command to delete old snapshots
aws ec2 describe-snapshots \
  --region $AWS_REGION \
  --filters "Name=volume-id,Values=$VOLUME_ID" \
  --query "Snapshots[?StartTime<=\`$(date --date="-${RETENTION_DAYS} days" +%Y-%m-%d)\`].SnapshotId" \
  --output text \
  | xargs --no-run-if-empty aws ec2 delete-snapshot --region $AWS_REGION --snapshot-id