
cd /root/bin

./do_mysql_backup.sh /web/parlo-tracker/curriculum/shared/config/database.yml /ext_data/backups/misc/db_one curriculum_db
./do_mysql_backup.sh /web/churn/scrape/shared/config/database.yml /ext_data/backups/misc/db_one churn_db
./do_files_backup.sh /web/churn/scrape/current/ /ext_data/backups/misc/files_one churn_current_files
./do_files_backup.sh /web/churn/scrape/shared/ /ext_data/backups/misc/files_one churn_shared_files
./do_files_backup.sh /web/parlo-tracker/curriculum/current/ /ext_data/backups/misc/files_one curriculum_current_files
./do_files_backup.sh /web/parlo-tracker/curriculum/shared/ /ext_data/backups/misc/files_one curriculum_shared_files

