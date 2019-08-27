#!/bin/bash

umask 077

source_dir=$1
dest_backup_dir=$2
environment=$3
max_backup_keep=$(($4+0))

# remove oldest files in dest_backup_dir ($2) till only max_backup_keep ($4) are left
function trim_backups () {
  arch_files=(`ls -rt ${dest_backup_dir}`) #reverse list of files in an array
  count=${#arch_files[@]}
  if [ $count -gt ${max_backup_keep} ]
  then
    del_count=`expr $count - ${max_backup_keep}`
    del_count=`expr $del_count - 1` #normalize for zero based array
    for i in $(seq 0 $del_count)
    do
      rm ${dest_backup_dir}/${arch_files[$i]}
    done
  fi
}

# format of date stamp on backup filename to only show hour and not include minutes and seconds
date=`date '+%Y-%m-%d_%H'`
# date=`date '+%Y-%m-%d_%H:%M:%S'`
    
backup_file=${environment}_$date.gz

echo "tar -czf ${dest_backup_dir}/${backup_file} -C ${source_dir} ."
tar -czf ${dest_backup_dir}/${backup_file} -C ${source_dir} .

if (( $max_backup_keep > 0 ))
then
  trim_backups
fi

### example backup command
### argument 1 - source directory
### argument 2 - directory to store backup files
### argument 3 - backup name preface to indicate environment, backup type, etc.
### argument 4 - number of backups to keep in backup directory ($2)
# do_files_backup /web/parlo-tracker/proui/current/public/system /ext-root/file_backups/StemEgypt testing 14

