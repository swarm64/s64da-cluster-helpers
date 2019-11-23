#!/bin/bash

set -e
set -x

nc -vv -lk -p 6464 > /tmp/s64cluster.dat &

n=1
tail -f /tmp/s64cluster.dat | while read LINE; do
    IFS=' ' read -r -a node_info <<< $LINE
    instance_id=${node_info[0]}
    instance_ip=${node_info[1]}

    dn="dn${n}"
    echo "$instance_ip $dn $instance_id" >> /etc/hosts

    echo "# BACKEND NODE $dn CONFIG FOR $instance_ip $instance_id
backend_hostname${n} = '$dn'
backend_port${n} = 5432
backend_weight${n} = 1
backend_data_directory${n} = '/data/postgresql'
backend_flag${n} = 'ALLOW_TO_FAILOVER'
    " >> /etc/pgpool2/pgpool.conf

    service pgpool2 restart

    ((n=n+1))
done
