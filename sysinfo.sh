#!/bin/bash
# Script used to grab system related infomation from local/remote systems

read -ep "Please enter host to connect to: " sshhost
read -ep "Please enter username to connect with: " sshuser
read -ep "Please enter port to connect to: " sshport

remote_connect () {
ssh -p "$sshport" "$sshuser"@"$sshhost"
}

disk_usage () { # report file system disk space usage
local sum=$(df -H)

printf "File System Disk Usage: \n %s \n\n" "$sum"
}

#disk_use () {
#local dir="$1"
#local sum=$(du -csh "$dir")

#printf "Disk Usage Summary for directory: $dir \n %s \n" "$sum"
#}

cpu_info () {
local cpu_load=$(cat /proc/loadavg)
local cpu_model=$(cat /proc/cpuinfo | grep '^model name' | uniq | awk -F': ' '{ print $2 }')
local cpu_cores=$(cat /proc/cpuinfo | grep '^cpu cores' | uniq | awk -F': ' '{ print $2 }')
local cpuinfo=$(dmidecode -t 'processor' | tail -n+5 | head -n-1)

printf "CPU Model: %s \n" "$cpu_model"
printf "Number of Cores: %d \n" "$cpu_cores"
printf "\nCPU Information: %s \n\n" "$cpuinfo"
printf "CPU Load Average: %s \n\n" "$cpu_load"
}

memory_info () {
local memtotal=$(cat /proc/meminfo | grep '^MemTotal:' | awk '{ print $2 }')
local memfree=$(cat /proc/meminfo | grep '^MemFree:' | awk '{ print $2 }')

printf "Total Memory: %d \n" "$memtotal"
printf "Free Memory: %d \n\n" "$memfree"
}

system_hardware_info () {
local mobo_info=$(dmidecode -t 'baseboard' | tail -n+5 | head -n-1)
local bios_info=$(dmidecode -t 'bios' | tail -n+5 | head -n-1)
local system_info=$(dmidecode -t 'system' | tail -n+5 | head -n-1)

printf "\nMotherBoard Information: %s \n\n" "$mobo_info"
printf "\nBIOS Information: %s \n\n" "$bios_info"
printf "\nSystem Information: %s \n\n" "$system_info"
}

system_name () {
local hname=$(hostname -s)
local fname=$(hostname -f)

printf "Hostname: %s \n" "$hname"
printf "Full Hostname: %s \n\n" "$fname"
}

running_services () {
local services=$(service --status-all | grep 'running...' | grep -v 'xfers')
local num=$(service --status-all | grep 'running...' | grep -v 'xfers' | wc -l)

printf "The current running services are: %s \n" "$services"
print "The number of running services is: %d \n\n" "$num"
}

if [[ "$sshhost" != 'localhost' && "$sshhost" != '127.0.0.1' ]]; then

  remote_connect <<EOF
$(declare -f system_name)
$(declare -f cpu_info)
$(declare -f memory_info)
$(declare -f disk_usage)

echo -e "\nGathering System Related Information on the machine now, please be patient...\n\n"

system_name
cpu_info
memory_info
disk_usage

echo -e "\nDone! Please review the above displayed infomation."
EOF

else

echo -e "\nGathering System Related Information on the machine now, please be patient...\n\n"

system_name
cpu_info
memory_info
disk_usage

echo -e "\nDone! Please review the above displayed infomation."

fi
