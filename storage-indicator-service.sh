#!/bin/bash

Device='nvme0n1'

while :
do
    sudo smartctl -i -a /dev/${Device} | awk '/Temperature:/{print $2; exit}' > device.t
    sleep 5
done
