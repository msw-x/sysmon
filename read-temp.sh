#!/bin/bash
sudo smartctl -i -a /dev/$1 | awk '/Temperature:/{print $2; exit}'