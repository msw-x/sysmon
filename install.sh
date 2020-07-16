#!/bin/bash

User=$(who | awk '(NR == 1)' | awk '{print $1}')
Home='/home/'$User

DstDir=/opt/storage-indicator
ServiceDir=/etc/systemd/system/
AutostartDir=${Home}/.config/autostart

AppFiles='
    hdd-32.png
    conf.py
    storage-indicator.py
    storage-indicator-service.sh
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
Exec "mkdir -p ${AutostartDir}"
Exec "cp storage-indicator.desktop ${AutostartDir}"

echo '[Install service]'
Exec "cp storage-indicator.service ${ServiceDir}"
Exec "systemctl enable storage-indicator"
Exec "systemctl start storage-indicator"

echo '[Installation completed successfully]'
