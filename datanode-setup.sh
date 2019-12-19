#!/bin/bash

aws_region=$1
s3_bucket=$2
frontend_ip=$3

apt update
apt install -y unzip
cd /tmp

awscli=d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip
curl https://$awscli -o "awscliv2.zip"

unzip awscliv2.zip
./aws/install

aws2 s3 --no-sign-request --region ${aws_region} \
  cp s3://${s3_bucket}/frontend_key.pub /tmp/frontend_key.pub
cat /tmp/frontend_key.pub >> /home/ubuntu/.ssh/authorized_keys

echo "169.254.169.254 instance-data" >> /etc/hosts

service swarm64da start

instance_id=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`
instance_ip=`wget -q -O - http://169.254.169.254/latest/meta-data/local-ipv4`
echo "$instance_id $instance_ip" | nc -q0 $frontend_ip 6464
