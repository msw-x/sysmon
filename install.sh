#!/bin/bash

DstDir=/opt/storage-indicator

User=$(who | awk '(NR == 1)' | awk '{print $1}')
Home='/home/'$User

AppFiles='
    hdd-32.png
    read-temp.sh
    conf.py
    storage-indicator.py
'

PrintCommands=1
PerformCommands=1

function Echo {
    if [[ $PrintCommands == 1 ]]; then
        echo $@
    fi
}

function Fatal {
    msg=$*
    echo "[ERROR]: ${msg}"
    exit 1
}

function Exec {
    Echo $1
    if [[ $PerformCommands == 1 ]]; then
        if ! eval $1; then
            Fatal
        fi
    fi
}

echo '[Install app]'
Exec "mkdir -p ${DstDir}"
for i in $AppFiles; do
    Exec "cp $i ${DstDir}"
done
Exec "cp storage-indicator.desktop ${Home}/.config/autostart"

echo '[Install service]'
Exec "cp storage-indicator.service ${ServiceDir}"
Exec "systemctl enable storage-indicator"
Exec "systemctl start storage-indicator"

echo '[Installation completed successfully]'
