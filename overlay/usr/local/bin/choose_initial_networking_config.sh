#!/bin/sh
set -x
ARGS=""
PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/root/bin"
for ints in `ifconfig | grep metric | cut -d \: -f1`; do
	INT_DESC=`dmesg | grep ${ints} | head -n 1 | cut -d \< -f2 | cut -d \> -f1 | tr ' ' '_'`
	ARGS="${ARGS} ${ints} \"${INT_DESC}\" disabled"
done

result=$( dialog --radiolist "choose initial network configuration" 300 300 200 $ARGS --output-fd 1)

ifconfig bridge0 addm ${result}
sysrc -f /persist/rc.conf ifconfig_bridge0="addm $result"
