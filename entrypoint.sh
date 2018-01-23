#!/bin/bash -e

# installing mysql credentials if file does not exist
mysql_config="/root/.my.cnf"
if [ ! -f "$mysql_config" ]; then
    echo '[xtrabackup]' > /root/.my.cnf
    echo "user=$MYSQL_USER" >> /root/.my.cnf
    echo "password=$MYSQL_PASS" >> /root/.my.cnf
    echo "host=$MYSQL_HOST" >> /root/.my.cnf
    echo "port=$MYSQL_PORT" >> /root/.my.cnf
fi

# installing crontab from env
echo "$CRON" | crontab -
crontab -l

# run cron in foreground
cron -f
