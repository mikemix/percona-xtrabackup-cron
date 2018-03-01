# percona-xtrabackup-cron

Dockerized hot MySQL backup with [Percona Xtrabackup](https://www.percona.com/software/mysql-database/percona-xtrabackup) under cron.

## Setup

Setup is done through a number of environment variables:

| **Variable name** | **Description**     | **Example**                                                                                |
|-------------------|---------------------|--------------------------------------------------------------------------------------------|
| CRON              | Cron rules to run   | Do backup at 01:00am each day: `0 1 * * *  backup _name_ "--compress" >/dev/console  2>&1` |
| TZ                | The time zone       | Europe/Berlin                                                                              |
| MYSQL_HOST        | MySQL host name     | 172.17.0.1                                                                                 |
| MYSQL_PORT        | MySQL port          | 3306                                                                                       |
| MYSQL_USER        | MySQL user          | root                                                                                       |
| MYSQL_PASS        | MySQL user password | [your password here]                                                                       |

`MYSQL_` variables are used to connect to the database. You can omit these settings and mount a custom `.cnf` file to the
[`/root/.my.cnf`](https://github.com/mikemix/percona-xtrabackup-cron#example-mycnf-file) inside the container.

### Example `.my.cnf` file

    [xtrabackup]
    user=user
    password=password
    host=host
    port=port
    # any other settings here if you wish

## Container commands

| **Command**  | **Description**                                                                                                                               |
|--------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| xtrabackup   | [The Percona Xtrabackup binary](https://www.percona.com/software/mysql-database/percona-xtrabackup)                                           |
| backup       | `xtrabackup` proxy. First argument stands for the backup name (eg. `rancher`), second are xtrabackup additional parameters (eg. `--compress`) |

## Standalone Docker setup

Example setup to backup [Rancher](https://rancher.com/) database periodically.

    docker run -it --rm -d --restart=unless-stopped --name backup-rancher \
        # path to mysql physical files (read only for security)
        -v /var/lib/mysql:/var/lib/mysql:ro \
        # storage location
        -v /mnt/backup/rancher:/mnt/backup/rancher \
        # backup log (not required)
        -v /var/backup/backup.log:/var/backup.log \

        -e CRON='0 1 * * * backup rancher "--compress --compress-threads=4" >/dev/console 2>&1' \
        -e TZ=Europe/Warsaw \
        -e MYSQL_HOST='172.17.0.1' -e MYSQL_PORT=3306 -e MYSQL_USER=root -e MYSQL_PASS=password

Make sure the backup location directory name matches your backup name that you set up in the cron rule. 
This will ensure symlinks created in the container are also usable on your host machine. In this case
backup name `rancher` matches the `rancher` directory inside `/mnt/backup` as all backups are stored
in the `/mnt/backup` inside the container.

The `--backup --target-dir=/path` arguments are added automatically.

## Backup log

If a physical file is mounted to the container's `/var/backup.log` location tool will prepend the file
after a successful backup with a CSV line:

    [unix time];[yyyy-mm-dd hh:mm:ss];[log name];[log size (eg. 32M)];[log path]

We then use this file to generate a [Jekyll based](https://jekyllrb.com/) HTML report.

