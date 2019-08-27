# weekly_backup.sh

cd /root/bin

./do_mysql_backup.sh ./wp_annie_cfg.yml /ext_data/backups/wp_annie/db_weekly wp_annie 4
./do_mysql_backup.sh ./wp_main_cfg.yml /ext_data/backups/wp_main/db_weekly wp_main 4
./do_mysql_backup.sh ./math_images_cfg.yml /ext_data/backups/math_images/db_weekly math_images 4
./do_mysql_backup.sh /web/parlo-tracker/proui/current/config/database.yml /ext_data/backups/stem_egypt/db_weekly stem_egypt 4
./do_mongo_backup.sh ./vmt_prod_cfg.yml /ext_data/backups/vmt_prod/db_weekly vmt_prod 4
./do_mongo_backup.sh ./encompass_prod_cfg.yml /ext_data/backups/encompass_prod/db_weekly encompass_prod 4
./do_files_backup.sh /web/parlo-tracker/proui/current/public/system /ext_data/backups/stem_egypt/files_weekly stem_egypt_files 4
./do_files_backup.sh /web/mathematicalthinking/apache /ext_data/backups/math_files/files_weekly mt_files 4
./do_files_backup.sh /web/mathematicalthinking/apache /ext_data/backups/math_files/files_weekly mt_files 4
./do_files_backup.sh /web/mathematicalthinking/blogs/afetter29 /ext_data/backups/wp_annie/files_weekly blog_dir 4
./do_files_backup.sh /web/mathematicalthinking/blogs/main /ext_data/backups/wp_main/files_weekly blog_dir 4
./do_files_backup.sh /etc/httpd /ext_data/backups/misc/files_weekly httpd 4
./do_files_backup.sh /root/bin /ext_data/backups/misc/files_weekly root_bin 4
./do_files_backup.sh /etc /ext_data/backups/misc/files_weekly etc_dir 4
./do_files_backup.sh /web/mathematicalthinking/mathimages/current /ext_data/backups/math_images/files_weekly math_images 4
./do_mongo_backup.sh ./mtlogin_prod_cfg.yml /ext_data/backups/mtlogin_prod/db_weekly mtlogin_prod 4
