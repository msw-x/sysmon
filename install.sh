#!/bin/bash

User=$(who | awk '(NR == 1)' | awk '{print $1}')
Home='/home/'$User

DstDir=/opt/sysmon
AutostartDir=${Home}/.config/autostart

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

echo '[Install]'
Exec "sudo mkdir -p $DstDir"
for i in $AppFiles; do
    Exec "sudo cp $i $DstDir"
done
Exec "mkdir -p $AutostartDir"
Exec "cp sysmon.desktop $AutostartDir"
Exec "pip3 install psutil"
Exec "sudo apt install gir1.2-appindicator3-0.1"

echo '[Installation completed successfully]'
