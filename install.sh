#!/bin/bash

DstDir=/opt/sysmon
ServiceDir=/etc/systemd/system/

AppFiles='
    icon.svg
    conf.py
    sysmon.py
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
    echo "[ERROR]: $msg"
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
Exec "sudo mkdir -p $DstDir"
for i in $AppFiles; do
    Exec "sudo cp $i $DstDir"
done
Exec "pip3 install psutil"

echo '[Install service]'
Exec "sudo cp sysmon.service $ServiceDir"
Exec "sudo systemctl enable sysmon"
Exec "sudo systemctl start sysmon"

echo '[Installation completed successfully]'
