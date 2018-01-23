#!/bin/bash -e

##
# Log success message if log file exists
#
# $1 Backup name (eg. rancher)
# $2 Full backup path
#
function success {
    log_file="/var/backup.log"

    if [ -f "$log_file" ]; then
        dir_size=`du -sh $2 | cut -f 1`
        echo -e "$(date +"%s;%Y-%m-%d %H:%M:%S");$1;$dir_size;$2\n$(cat $log_file)" > $log_file
    fi
}

##
# xtrabackup proxy
#
# $1 Backup name (eg. rancher)
# $2 Xtrabackup additional command args (eg. --compress)
#

backup_path="/mnt/backup/$1/$(date +'%Y/%m/%d/%s')"
mkdir -p "$backup_path"

echo "Backup start in: $backup_path"

`xtrabackup --target-dir=$backup_path --backup $2`

if [[ "$2" != *"incremental-basedir"* ]]; then
    ln -sf "$backup_path" "/mnt/backup/$1/latest-full"
fi

ln -sf "$backup_path" "/mnt/backup/$1/latest"

success "$1" "$backup_path"
echo 'Backup complete'
