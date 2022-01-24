# backup_shell
backup for linux


## config file
    # cat /home/backups/conf/host_name

    ## directory rsync
    /var/www/vhost/:vhost

    ## file rsync
    /var/spool/cron/root:cron_root

    ## mysqldump all
    mysql:all

    ## mysqldump each db
    #mysql:hogedb

## cron
    # crontab -l
    PATH=/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

    10 0 * * * backup.sh -H root@hogehost -l hogehost -p day > /var/log/backup_day.log 2>&1
    10 1 1 * * backup.sh -H root@hogehost -l hogehost -p month > /var/log/backup_month.log 2>&1

    ## case of add hosts 
    10 0 * * * backup.sh -H hogehost -p day > /var/log/backup_day.log 2>&1
    10 1 1 * * backup.sh -H hogehost -p month > /var/log/backup_month.log 2>&1
