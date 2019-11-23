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

function copy_to_s3 {
    aws2 s3 --no-sign-requres --region ${aws_region} \
    cp $1 s3://${s3_bucket/$(basename $1)
}

ssh-keygen -b 2048 -t rsa -f /root/s64dacluster -q -N ""
copy_to_s3 /root/s64dacluster.pub
