#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
    echo "Error: run this script as root." >&2
    exit 1
fi

cat >/usr/local/bin <<EOF
arch=$(uname -a)
cpuf=$(grep "physical id" /proc/cpuinfo | wc -l)
cpuv=$(grep "processor" /proc/cpuinfo | wc -l)
ram_total=$(free --mega | awk '$1 == "Mem:" {print $2}')
ram_use=$(free --mega | awk '$1 == "Mem:" {print $3}')
ram_percent=$(free --mega | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')
disk_total=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_t += $2} END {printf ("%.1fGb\n"), disk_t/1024}')
disk_use=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} END {print disk_u}')
disk_percent=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} {disk_t+= $2} END {printf("%d"), disk_u/disk_t*100}')
cpul=$(vmstat 1 2 | tail -1 | awk '{printf $15}')
cpu_op=$(expr 100 - $cpul)
cpu_fin=$(printf "%.1f" $cpu_op)
lb=$(who -b | awk '$1 == "system" {print $3 " " $4}')
lvmu=$(if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; then echo yes; else echo no; fi)
tcpc=$(ss -ta | grep ESTAB | wc -l)
ulog=$(users | wc -w)
ip=$(hostname -I)
mac=$(ip link | grep "link/ether" | awk '{print $2}')
cmnd=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

report ="Architecture: $arch
	CPU physical: $cpuf
	vCPU: $cpuv
	Memory Usage: $ram_use/${ram_total}MB ($ram_percent%)
	Disk Usage: $disk_use/${disk_total} ($disk_percent%)
	CPU load: $cpu_fin%
	Last boot: $lb
	LVM use: $lvmu
	Connections TCP: $tcpc ESTABLISHED
	User log: $ulog
	Network: IP $ip ($mac)
	Sudo: $cmnd cmd"

logger -t monitoring "report"
EOF
chmod 755 /usr/local/bin/monitoring.sh

CRON_JOB="*/10 * * * * sh /usr/local/bin/monitoring.sh"
(crontab -u root -l 2>/dev/null | grep -Fv "$CRON_JOB"; echo "$CRON_JOB") | crontab -u root -
