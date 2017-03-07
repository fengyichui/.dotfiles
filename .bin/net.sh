
#!/bin/bash
# 统计网卡流量
# link：www.jb51.net
# date：2013/2/26
n=10

date
rm -rf /tmp/ifconfig_log
while (( $n >= 0 ))
do
n=$(($n - 1));
date >> /tmp/ifconfig_log
ifconfig eth1 >> /tmp/ifconfig_log
sleep 1
done

grep "RX bytes:" /tmp/ifconfig_log | awk -F"[:| ]" '{print $13}' | awk 'BEGIN{tmp=$1}{if(FNR > 1)print $1-tmp}{tmp=$1}'
