#!/bin/bash

# Check if the script is being run by root

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root"
   exit 1
fi

# Check if dmidecode is being installed

if [ $(dpkg-query -W -f='${Status}' dmidecode 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  apt-get install -y dmidecode > /dev/null;
fi

scriptdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
exec 1>$scriptdir/task4_1.out

hwinfo="--Hardware--"
cpuinfo=$(cat /proc/cpuinfo | grep 'model name' | uniq | awk -F ': ' '{print$2}')
meminfo=$(cat /proc/meminfo | grep 'MemTotal' | awk -F ': ' '{print$2}')
boardinfo=$(dmidecode -s baseboard-product-name && dmidecode -s baseboard-manufacturer)
uuidinfo=$(dmidecode -s system-serial-number)
sysinfo="--System--"
releaseinfo=$(lsb_release -d | awk '{print $2 ,$3}')
kernelinfo=$(uname -r)
installinfo=$(fs=$(df / | tail -1 | cut -f1 -d' ') && tune2fs -l $fs | grep created | awk -F ":" '{print$2,$3,$4}')
hostinfo=$(hostname)
uptimeinfo=$(uptime -p)
processinfo=$(ps aux | wc -l)
userinfo=$(users | wc -w)
networkinfo="--Network--"

echo $hwinfo
echo 'CPU:' $cpuinfo
echo 'RAM:' $meminfo
echo 'Motherboard:' $boardinfo
echo 'System Serial Number:' $uuidinfo
echo $sysinfo
echo 'OS Distribution:' $releaseinfo
echo 'Kernel version:' $kernelinfo
echo 'Installation date:' $installinfo
echo 'Hostname:' $hostinfo
echo 'Uptime:' $uptimeinfo
echo 'Processes running:' $processinfo
echo 'Users logged in:' $userinfo
echo $networkinfo

for i in $(ip a list | awk -F:' ' '{print $2}' | sed '/^$/d'); do
  if [ -z "$(ip -4 a s "$i" | grep inet | sed 's/^ *//g' | awk -F' ' '{print $2}')" ]; then
    echo "$i: -"
  else
    echo -n "${i}: " && echo `ip -4 a s "$i" | grep inet | sed 's/^ *//g' | awk -F' ' '{print $2}'`
  fi
done

