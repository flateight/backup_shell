#!/bin/bash

BACKUP_DIR=/home/backups
BACKUP_LIST=${BACKUP_DIR}/conf
TAR_OP="--sparse --one-file-system -zcp --numeric-owner --xattrs ."
usage_exit() {
        echo "Usage: $0 [-H host] [-p period type] [-l list_file] " 1>&2
        exit 1
}

while getopts p:H:l:h: OPT
do
    case $OPT in
        H)  BAKHOST=$OPTARG
        ;;
        p)  PERIOD=$OPTARG
            ;;
        l)  LIST=$OPTARG
            ;;
        u)  USER=$OPTARG
            ;;
        h)  usage_exit
            ;;
        \?) usage_exit
            ;;
    esac
done

shift $(($OPTIND - 1))

if [ -z $LIST ];then
    LIST=${BAKHOST#*@}
fi

#exit;
function dir_check(){
    dir=$1
    if [ ! -d $dir ];then
        mkdir -p $dir
    fi
}
function period_check(){
    if [ $1 == 'day' ];then
        PDIR=$(date +%a)
    elif [ $1 == 'month' ];then
        PDIR=$(date +%m)
    else
        echo "Error period type."
        exit;
    fi
}
function list_check(){
    if [ ! -d $BACKUP_LIST ];then
        dir_check $BACKUP_LIST
    fi

    BKLIST=$BACKUP_LIST/$LIST
    if [ ! -f $BKLIST ];then
        echo "Error list not found: $BKLIST"
        exit;
    fi
}
function backup(){
    list_check
    echo "backup_list: $BKLIST"
    echo "============="
    period_check $PERIOD
    BK_DIR=$BACKUP_DIR/$LIST/$PERIOD/$PDIR

    while read LINE
    do
        if [ "${LINE:0:1}" == "#" -o -z "${LINE}" ];then
            continue
        fi


        echo "backup: $LINE"
        DIR=${LINE%:*}
        FILE_NAME=${LINE#*:}
        dir_check $BK_DIR

        if [ "${DIR}" == 'mysql' ];then

            dir_check $BK_DIR/DB
            if [ "${FILE_NAME}" == "all" ];then
                ssh $BAKHOST "mysqldump --all-databases " | gzip | cat > $BK_DIR/DB/all.sql.gz
            else
                ssh $BAKHOST "mysqldump ${FILE_NAME} " | gzip | cat > $BK_DIR/DB/$FILE_NAME.sql.gz
            fi
        elif [ "${DIR: -1}" == '/' ];then
            ##ssh $BAKHOST "tar -C $DIR $TAR_OP"|  cat > $BK_DIR/$FILE_NAME.tar.gz
            echo "rsync -a $BAKHOST:$DIR $BK_DIR/$FILE_NAME/"
            rsync -a $BAKHOST:$DIR $BK_DIR/$FILE_NAME/
        else
            echo "rsync -a $BAKHOST:$DIR $BK_DIR/$FILE_NAME"
            rsync -a $BAKHOST:$DIR $BK_DIR/$FILE_NAME
        fi
    done < $BKLIST
}


backup
exit;
