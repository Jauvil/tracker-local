#!/bin/bash

umask 077

config_file=$1
backup_path=$2
environment=$3
max_backup_keep=$(($4+0))

#gets a field from database.yml (specified in argument $1)
function get_field () {
  line=`grep $1 $config_file` #grep the line
  value=${line##*:} #get the value
  value=`echo $value | tr -d ''` #remove all white spaces
  echo $value
}

# remove oldest files in backup_path ($2) till only max_backup_keep ($4) are left
function trim_backups () {
  arch_files=(`ls -rt $backup_path`) #reverse list of files in an array
  count=${#arch_files[@]}
  if [ $count -gt $max_backup_keep ]
  then
    del_count=`expr $count - $max_backup_keep`
    del_count=`expr $del_count - 1` #normalize for zero based array
    for i in $(seq 0 $del_count)
    do
      rm $backup_path/${arch_files[$i]}
    done
  fi
}

pwd=`get_field password`
user=`get_field username`
database=`get_field database`

# format of date stamp on backup filename to only show hour and not include minutes and seconds
date=`date '+%Y-%m-%d_%H'`
# date=`date '+%Y-%m-%d_%H:%M:%S'`
backup_file=${environment}_${database}_$date.sql.gz

/usr/bin/mysqldump -u $user --password=$pwd $database | /usr/bin/gzip -9 > $backup_path/$backup_file

if (( $max_backup_keep > 0 ))
then
  trim_backups
fi

### example backup command
### command - do_mysql_backup.sh
### argument 1 - database.yml (configuration file with access to database)
### argument 2 - directory to store backup files
### argument 3 - backup name preface to indicate environment, backup type, etc.
### argument 4 - number of backups to keep in backup directory ($2)
# /root/bin/do_mysql_backup.sh /root/bin/testing_cfg.yml /ext_data/db_backups/testing testing 14
