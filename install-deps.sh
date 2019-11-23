#!/bin/bash

set -e

cd /root

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BA9EF27F
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -c -s)-pgdg main" >> /etc/apt/sources.list

apt update
apt install -y unzip postgresql-client-11 pgpool2

cd /tmp

awscli=d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip
curl https://$awscli -o "awscliv2.zip"

unzip awscliv2.zip
./aws/install

# Fix pgpool2 config
PGPOOL_CONFIG_DIR=/etc/pgpool2
PGPOOL_CONFIG="$PGPOOL_CONFIG_DIR/pgpool.conf"

# Configure pgpool2
sed -i 's/^backend_/#backend_/g' $PGPOOL_CONFIG
sed -i 's/^\(listen_addresses\).*$/\1 = '\''*'\''/' $PGPOOL_CONFIG
sed -i 's/^\(replication_mode\).*$/\1 = on/' $PGPOOL_CONFIG
sed -i 's/^\(failover_if_affected_tuples_mismatch\).*$/\1 = on/' $PGPOOL_CONFIG
sed -i 's/^\(load_balance_mode\).*$/\1 = on/' $PGPOOL_CONFIG
# TODO: add S64 DA maintenance functions
sed -i 's/^\(black_function_list\).*$/\1 = '\''currval,lastval,nextval,setval,pg_reload_conf,add_column_to,drop_column_from,change_optimized_columns_to'\''/' $PGPOOL_CONFIG
sed -i 's/^\(allow_sql_comments\).*$/\1 = on/' $PGPOOL_CONFIG
sed -i 's/^\(health_check_period\).*$/\1 = 60/' $PGPOOL_CONFIG
sed -i 's/^\(health_check_user\).*$/\1 = '\''postgres'\''/' $PGPOOL_CONFIG
sed -i 's/^\(ssl\s\+=\).*$/\1 on/' "$PGPOOL_CONFIG"

# Set up PCP
PGPOOL_USER=pgpool
PGPOOL_PASS=pgpool
echo "$PGPOOL_USER:$( pg_md5 $PGPOOL_PASS )" > $PGPOOL_CONFIG_DIR/pcp.conf

PCPPASS="/root/.pcppass"
echo "127.0.0.1:9898:$PGPOOL_USER:$PGPOOL_PASS" > $PCPPASS

chmod 600 $PCPPASS
USER=$( ls -ld "$HOME" | awk '{print $3}' )
GROUP=$( ls -ld "$HOME" | awk '{print $4}' )
chown $USER:$GROUP $PCPPASS

# Restart pgpool
service pgpool2 restart
