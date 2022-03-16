#!/bin/bash

eth0_status=`mii-tool eth0 | awk {'print $6'}`
if test -z "$eth0_status" -o "$eth0_status" != "ok"
then
        systemctl start netctl-auto@wlan0 >& /dev/null
fi
