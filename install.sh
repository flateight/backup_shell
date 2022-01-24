#!/bin/bash

if [ -z ./bin ];then
    mkdir ~/bin
fi
cp -v ./backup.sh ~/bin/
chmod 755 /usr/local/bin/backup.sh
