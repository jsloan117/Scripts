#!/bin/bash
# Used to manage  openvz containers
# version: 1.0

list_vz_containers () {
local ctid="$1"

if [[ -z $ctid ]]; then

    vzlist -a

else

    vzlist -a "$ctid"

fi
}

list_templates () {
local ostemplates=$(ls -lh /vz/template/cache | tail -n+2 | awk '{ print $9 }' | sed 's|.tar.gz$||g')
#local conftemplate=$(ls -lh /etc/vz/conf/ | tail -n+2 | awk '{ print $9 }' | sed -e 's|^ve-||g' -e 's|.conf-sample$||g' | grep -vE "*.conf*")

for temp in "$ostemplates"; do

    echo -e "$temp"

done
}

create_vz_container () {
local ctid="$1"
local ostemplate="$2"
local conftemplate="$3"
local hostname="$4"
local ipadd="$5"
local nameservers="$6"

[[ -z "$conftemplate" ]] && conftemplate='basic'

vzctl create "$ctid" --ostemplate "$ostemplate" --config "$conftemplate" #--hostname "$hostname" --ipadd "$ipadd" --nameserver "$nameservers
#vzctl create "$ctid" --ostemplate "$ostemplate" --config "$conftemplate" --hostname "$hostname" --ipadd "$ipadd" --nameserver "$nameservers"
}

delete_vz_container () {
local ctid="$1"

control_container "$ctid" "stop"
control_container "$ctid" "destroy"
}

set_vz_parameters () {
local ctid="$1"
local parameter="$2" # hostname, ipadd, nameserver, onboot, userpasswd
local data="$3" # Value

if [[ "$parameter" = 'name' ]]; then

    vzctl set "$ctid" --name "$data" --save
    [[ ! -L /etc/vz/names/"$data" ]] && ln -vs ln -vs ../../../etc/vz/conf/"$ctid".conf /etc/vz/names/"$data"

else

    vzctl set "$ctid" --"$parameter" "$data" --save

fi
}


control_container () {
local ctid="$1"
local action="$2" # start, stop, restart, status values

vzctl "$action" "$ctid"
}

disable_container () {
local ctid="$1"
local action="$2"

if [[ "$action" = 'yes' ]]; then

    control_container "$ctid" "stop"
    set_vz_parameters "$ctid" "disabled" "yes"

elif [[ "$action" = 'no' ]]; then

    set_vz_parameters "$ctid" "disabled" "no"
    control_container "$ctid" "start"
    control_container "$ctid" "status"

fi
}

suspend_container () {
local ctid="$1"
local action="$2"

if [[ "$action" = 'suspend' ]]; then

    vzctl chkpnt "$ctid" --dumpfile /vz/dump/"$ctid".dump

elif [[ "$action" = 'restore' ]]; then

    vzctl restore "$ctid" --dumpfile /vz/dump/"$ctid".dump

fi
}

migrate_container () {
local ctid="$1"
local destsvr="$2"
local sshport="$3"
local status="$?"
[[ -z "$sshport" ]] && sshport='22'

#ssh-keygen -t rsa -b 4096
echo -e "\nYou must configure ssh-keys inbetween the source and destination servers for this to be successful. Have you done this? \n"

vzmigrate --remove-area no --ssh=-p"$sshport" "$destsvr" "$ctid"

if [[ "$status" = '0' ]]; then

    echo -e "\nMigration was successful\n"

else

    echo -e "\nError code: $status -- You may wish to man vzmigrate and check the exit code\n"

fi
}

create_snapshot () {
local ctid="$1"

vzctl snapshot "$ctid" --name "$ctid-Snapshot"
}

help_menu () {
version='1.0'
prog="$(echo $(basename $0))"

cat <<EOF
This script is used to manage openvz containers. You can list, create, delete, and set parameters of the virtual machine.
  $prog <[-l|--list] [-lt|--listtemplates] [-c|--create] [-d|--delete] [-s|--set] [-cc|--control] [-dc|--lock] [-sc|--suspend] [-m|--migrate] [-h|--help]>
  Example: $prog -l 102
           $prog -c 102 centos-6-x86_64
           $prog -s hostname hostname.domain.com
           $prog --set ipadd 192.168.2.102
           $prog -s nameserver "8.8.8.8 8.8.4.4"
           $prog -cc 102 (start|stop|restart|status)
           $prog --lock 102 {yes|no)
           $prog --suspend 102 (suspend|restore)

  version: $version
EOF
}

selection="$1"

case "$selection" in

  -l|--list)

    shift
    list_vz_containers $1 ;;

  -lt|--listtemplates)

    list_templates ;;

  -c|--create)

    shift
    create_vz_container $@ ;;

  -d|--delete)

    shift
    delete_vz_container $1 ;;

  -s|--set)

    shift
    set_vz_parameters $@ ;;

  -cc|--control)

    shift
    control_container $@ ;;

  -dc|--lock)

    shift
    disable_container $@ ;;

  -sc|--suspend)

    shift
    suspend_container $@ ;;

  -m|--migrate)

    shift
    migrate_container $@ ;;

  -h|--help)

    help_menu ;;

  *)

    help_menu ;;

esac
