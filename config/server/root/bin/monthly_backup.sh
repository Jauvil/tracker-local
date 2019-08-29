
cd /root/bin

./do_mysql_backup.sh ./wp_annie_cfg.yml /ext_data/backups/wp_annie/db_monthly wp_annie 12
./do_mysql_backup.sh ./wp_main_cfg.yml /ext_data/backups/wp_main/db_monthly wp_main 12
./do_mysql_backup.sh ./math_images_cfg.yml /ext_data/backups/math_images/db_monthly math_images 12
./do_mysql_backup.sh /web/parlo-tracker/proui/current/config/database.yml /ext_data/backups/stem_egypt/db_monthly stem_egypt 12
./do_mongo_backup.sh ./vmt_prod_cfg.yml /ext_data/backups/vmt_prod/db_monthly vmt_prod 12
./do_mongo_backup.sh ./encompass_prod_cfg.yml /ext_data/backups/encompass_prod/db_monthly encompass_prod 12
./do_files_backup.sh /web/parlo-tracker/proui/current/public/system /ext_data/backups/stem_egypt/files_monthly stem_egypt_files 12
./do_files_backup.sh /web/mathematicalthinking/apache /ext_data/backups/math_files/files_monthly mt_files 12
./do_files_backup.sh /web/mathematicalthinking/apache /ext_data/backups/math_files/files_monthly mt_files 12
./do_files_backup.sh /web/mathematicalthinking/blogs/afetter29 /ext_data/backups/wp_annie/files_monthly blog_dir 12
./do_files_backup.sh /web/mathematicalthinking/blogs/main /ext_data/backups/wp_main/files_monthly blog_dir 12
./do_files_backup.sh /etc/httpd /ext_data/backups/misc/files_monthly httpd 12
./do_files_backup.sh /root/bin /ext_data/backups/misc/files_monthly root_bin 12
./do_files_backup.sh /etc /ext_data/backups/misc/files_monthly etc_dir 12
./do_files_backup.sh /web/mathematicalthinking/mathimages/current /ext_data/backups/math_images/files_monthly math_images 12
./do_mongo_backup.sh ./mtlogin_prod_cfg.yml /ext_data/backups/mtlogin_prod/db_monthly mtlogin_prod 12
