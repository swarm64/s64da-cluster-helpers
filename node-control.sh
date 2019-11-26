#!/bin/bash

NODES_INFO=/var/nodes
ASG_NAME=`aws2 autoscaling describe-auto-scaling-instances \
  --query AutoScalingInstances[1].AutoScalingGroupName`

function print_help {
  echo "Usage: $0 {attach|detach} <node-number>"
}

if [ -z ${1+x} ]; then
  echo "Please provide a command."
  print_help
  exit -1
else
  CMD=$1
fi

if [ -z ${2+x} ]; then
  echo "Please provide a node number."
  print_help
  exit -1
else
  NODE=$2
fi

NODE_ID=`awk -v num=$NODE '$1 == num {print $2}' $NODES_INFO`

case $CMD in
  "attach")
    echo "Attaching node $NODE ($NODE_ID)"
    aws2 start-instances --instance-ids $NODE_ID
    aws2 autoscaling attach-instances --instance-ids $NODE_ID \
      --auto-scaling-group-name $ASG_NAME
    pcp_attach_node -h 127.0.0.1 -U pgpool -p 9898 -n $NODE -w
    ;;
  "detach")
    echo "Detaching node $NODE ($NODE_ID)"
    pcp_detach_node -h 127.0.0.1 -U pgpool -p 9898 -n $NODE -g
    aws2 autoscaling detach-instances --instances-ids $NODE_ID \
      --auto-scaling-group-name $ASG_NAME \
      --should-decrement-desired-capacity
    aws2 start-instances --instance-ids $NODE_ID
    ;;
  *)
esac
