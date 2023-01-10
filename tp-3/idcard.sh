#!/bin/bash
# programme idcard

name="$(hostnamectl | grep 'Transient hostname' | cut -d ':' -f2)"
nameOS="$(cat /etc/redhat-release)"
verNoyau="$(uname -r)"
ip="$(ip -4 addr show enp0s1 | grep inet | tr -s ' ' |cut -d ' ' -f3)"
freeRam="$(free -h | grep 'Mem:' | tr -s ' ' | cut -d' ' -f4)"
totalRam="$(free -h | grep 'Mem:' | tr -s ' ' | cut -d' ' -f2)"
freeDisk="$(df -h -a -t xfs | grep 'rl-root' | tr -s ' ' | cut -d ' ' -f4)"
topProcessRam="$(ps -eo pmem,cmd | sort -rnk 1 | head -n 5 | cut -d' ' -f3)"

curl -s https://cataas.com/cat --output cat
typeImage="$(file --mime-type cat | cut -d ' ' -f2 | cut -d '/' -f2)"

echo "Machine name : ${name}"
echo "OS ${nameOS} and kernel version is ${verNoyau}"
echo "Ip : ${ip}"
echo "RAM: ${freeRam} memory available on ${totalRam} total memory"
echo "Top 5 processes by RAM usage :"
echo "${topProcessRam}"
echo "Listening ports :"
while read line; do
  type="$(echo $line | cut -d' ' -f1)"
  port="$(echo $line | cut -d' ' -f5 | cut -d':' -f2)"
  process="$(echo $line | cut -d' ' -f7 | cut -d '(' -f3 | cut -d ',' -f1)"

  echo "- $port $type : $process"

done <<< "$(sudo ss -alnptu4H )"

echo "Here is your random cat : ./cat.${typeImage}"