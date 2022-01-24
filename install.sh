#!/bin/bash

if [ -z ./bin ];then
    mkdir ~/bin
fi
cp -v ./backup.sh ~/bin/
chmod 755 ~/bin/backup.sh
