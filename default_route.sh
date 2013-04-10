#!/bin/bash
###################################
### Default route change script	###
### 2013041001			###
### Denis Bryzgalov		###
### admin@flashadmin.org	###
###################################

# Lockfile location
LOCKFILE=/var/lock/default_route.lock
# First provider ip address
IP1=1.1.1.1
# Second provider ip address
IP2=2.2.2.2
# First gateway device
GW1=ppp0
# Second gateway device
GW2=ppp1

# Checking for running instances
if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running"
    exit 1
fi
echo $$ > ${LOCKFILE}

# Adding routing tables
ip rule add from $IP1 lookup 101 > /dev/null 2>&1
ip route add table 101 dev $GW1 > /dev/null 2>&1
ip rule add from $IP2 lookup 102 > /dev/null 2>&1
ip route add table 102 dev $GW2 > /dev/null 2>&1

# Working part
while true
do
if [ `ip route list | grep default | grep -c 1` -eq 0 ] ; then
	# If all bad, set default route via another gateway
        ip route add default via 10.0.0.222
fi
if ping -I $IP1 -c 3 8.8.8.8 >& /dev/null 2>&1
then
        ip route change default dev $GW1
        echo "default route at $(date)" >> /var/log/default_route.log
else
        ping -I $IP2 -c 1 8.8.8.8 >& /dev/null && ip route change default dev $GW2
        echo "backup route set at $(date)" >> /var/log/default_route.log
fi
sleep 5
done
rm -f ${LOCKFILE}
exit 0
