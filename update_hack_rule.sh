#!/bin/bash

exec &>> /var/log/update_hack_rule.log
echo Runnning at $(date)..

NODEPORT_CHAIN=$(/sbin/iptables -t nat -vnL KUBE-NODEPORTS | awk '/tcp dpt:30365/ {print $3}')

[ -z "$NODEPORT_CHAIN" ] && exit 0

read HACK_CHAIN HACK_RULE_NO <<< "$(/sbin/iptables -t nat -vnL PREROUTING | awk '/tcp dpt:30345/ {print $3, NR-2}')"

[ "$NODEPORT_CHAIN" = "$HACK_CHAIN" ] && exit 0

echo "Chains differ: old $HACK_CHAIN, new $NODEPORT_CHAIN"

if [ -n "$HACK_CHAIN" ]
then
    /sbin/iptables -t nat -D PREROUTING $HACK_RULE_NO
fi

/sbin/iptables -t nat -I PREROUTING 1 -p tcp --dport 30345 -j $NODEPORT_CHAIN
