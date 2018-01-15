#! /bin/bash

rfkill unblock wlan

killall wpa_supplicant

wpa_supplicant -Dnl80211 -i wlan0 -c /etc/wpa_supplicant.conf &

udhcpc -i wlan0 -s /usr/share/udhcpc/default.script
