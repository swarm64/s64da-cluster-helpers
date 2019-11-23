#!/bin/bash

set -e

account_id=$1
aws_region=$2
s3_bucket=$3

mkdir -p /root/.aws
aws_credentials_file=/root/.aws/credentials
touch $aws_credentials_file
echo "[root]" >> $aws_credentials_file
echo "role_arn = arn:aws:iam::${account_id}:role/RootRole" >> $aws_credentials_file
echo "credential_source = Ec2InstanceMetadata" >> $aws_credentials_file

aws2 s3 --no-sign-request --region ${aws_region} \
  cp /etc/ssh/ssh_host_rsa_key.pub s3://${s3_bucket}/frontend_key.pub
