#!/bin/sh
sudo ss-local -c /etc/shadowsocks.json &
cd rjsupplicant
sudo chmod +x rjsupplicant.sh
sudo ./rjsupplicant.sh -u143401040116 -pwang123 -d1

