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
        echo 'Adding backup success log'
        dir_size=`du -sh $2 | cut -f 1`
        echo -e "$(date +"%s;%Y-%m-%d %H:%M:%S");$1;$dir_size;$2\n$(cat $log_file)" > $log_file
    fi
}

##
# xtrabackup proxy
#
# $1 Backup name (eg. rancher)
# $2 Xtrabackup command args (eg. --backup)
#

backup_path="/mnt/backup/$1/$(date +'%Y/%m/%d')/$(date +'%s')"
ln_full_path="/mnt/backup/$1/latest-full"
ln_latest_path="/mnt/backup/$1/latest"

echo "Backup start in: $backup_path"

mkdir -m 777 -p "$backup_path"
ln -sf "$backup_path" /backup

`xtrabackup $2`

if [[ "$2" != *"incremental-basedir"* ]]; then
    ln -sf "$backup_path" "$ln_full_path"
fi

ln -sf "$backup_path" "$ln_latest_path"

success "$1" "$backup_path"
echo 'Backup complete'
