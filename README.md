# percona-xtrabackup-cron

Dockerized hot MySQL backup with [Percona Xtrabackup](https://www.percona.com/software/mysql-database/percona-xtrabackup) under cron.

## Setup

Setup is done through a number of environment variables:

| **Variable name** | **Description**     | **Example**                                                                                   |
|-------------------|---------------------|-----------------------------------------------------------------------------------------------|
| CRON              | Cron rules to run   | Do backup at 01:00am each day: `0 1 * * *  backup backup_name "--backup" >/dev/console  2>&1` |
| TZ                | The time zone       | Europe/Berlin                                                                                 |
| MYSQL_HOST        | MySQL host name     | 172.17.0.1                                                                                    |
| MYSQL_PORT        | MySQL port          | 3306                                                                                          |
| MYSQL_USER        | MySQL user          | root                                                                                          |
| MYSQL_PASS        | MySQL user password | [your password here]                                                                          |

`MYSQL_` variables are used to connect to the database. You can omit these settings and mount a custom `.cnf` file to the
[`/root/.my.cnf`](https://github.com/mikemix/percona-xtrabackup-cron#example-mycnf-file) inside the container.

### Example `.my.cnf` file

    [xtrabackup]
    target-dir=/backup # this is mandatory as is
    user=user
    password=password
    host=host
    port=port
    # any other settings here if you wish

## Container commands

| **Command**  | **Description**                                                                                                                          |
|--------------|------------------------------------------------------------------------------------------------------------------------------------------|
| xtrabackup   | [The Percona Xtrabackup binary](https://www.percona.com/software/mysql-database/percona-xtrabackup)                                      |
| backup       | `xtrabackup` proxy. First argument stands for the backup name (eg. `rancher`), second is the xtrabackup tool parameters (eg. `--backup`) |

## Standalone Docker setup

Example setup to backup [Rancher](https://rancher.com/) database periodically.

    docker run -it --rm -d --name backup-rancher \
        # mysql data files
        -v /var/lib/mysql:/var/lib/mysql:ro \
        # path to mysql physical files (read only for security)
        -v /mnt/backup/rancher:/mnt/backup/rancher \
        # backup log (not required)
        -v /var/backup/backup.log:/var/backup.log \

        -e CRON='0 1 * * * backup rancher "--compress --compress-threads=4 --backup" > /dev/console 2>&1' \
        -e TZ=Europe/Warsaw \
        -e MYSQL_HOST='172.17.0.1' -e MYSQL_PORT=3306 -e MYSQL_USER=root -e MYSQL_PASS=password \
        
