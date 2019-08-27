
cd /root/bin

./do_mysql_backup.sh ./wp_annie_cfg.yml /ext_data/backups/wp_annie/db_daily wp_annie 7
./do_mysql_backup.sh ./wp_main_cfg.yml /ext_data/backups/wp_main/db_daily wp_main 7
./do_mysql_backup.sh ./math_images_cfg.yml /ext_data/backups/math_images/db_daily math_images 7
./do_mysql_backup.sh /web/parlo-tracker/proui/current/config/database.yml /ext_data/backups/stem_egypt/db_daily stem_egypt 7
./do_mongo_backup.sh ./vmt_prod_cfg.yml /ext_data/backups/vmt_prod/db_daily vmt_prod 7
./do_mongo_backup.sh ./encompass_prod_cfg.yml /ext_data/backups/encompass_prod/db_daily encompass_prod 7
./do_files_backup.sh /web/parlo-tracker/proui/current/public/system /ext_data/backups/stem_egypt/files_daily stem_egypt_files 7
./do_files_backup.sh /web/mathematicalthinking/apache /ext_data/backups/math_files/files_daily mt_files 7

