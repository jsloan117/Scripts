#!/bin/bash
# Used to manage  openvz containers
# version: 0.9

list_vz_containers () {
local CTID="$1"

if [[ -z $CTID ]]; then

    vzlist -a

else

    vzlist -a "$CTID"

fi
}

list_templates () {
local templates=$(ls -lh /vz/template/cache | tail -n+2 | awk '{ print $9 }' | sed 's|.tar.gz$||g')

for temp in "$templates"; do

    echo -e "$temp"

done
}

create_vz_container () {
local CTID="$1"
local OSTEMP="$2"

vzctl create "$CTID" --ostemplate "$OSTEMP" -–config basic
}

delete_vz_container () {
local CTID="$1"

vzctl stop "$CTID"
vzctl destroy "$CTID"
}

set_vz_parameters () {
local CTID="$1"
local parameter="$2" # hostname, ipadd, nameserver, onboot, userpasswd
local data="$3" # Value

if [[ "$parameter" = 'name' ]]; then

    vzctl set "$CTID" --name "$data" --save
    [[ ! -L /etc/vz/names/"$data" ]] && ln -vs /etc/vz/conf/"$CTID".conf /etc/vz/names/"$data"

fi

vzctl set "$CTID" --"$parameter" "$data" --save
}


control_container () {
local CTID="$1"
local state="$2" # start, stop, restart, status values

vzctl "$state" "$CTID"
}

disable_container () {
local CTID="$1"
local action="$2"

if [[ "$action" = 'yes' ]]; then

    vzctl set "$CTID" --disabled yes --save

elif [[ "$action" = 'no' ]]; then

    vzctl set "$CTID" --disabled no --save

fi
}

suspend_container () {
local CTID="$1"
local action="$2"

if [[ "$action" = 'suspend' ]]; then

    vzctl chkpnt "$CTID"

elif [[ "$action" = 'restore' ]]; then

    vzctl restore "$CTID"

fi
}

help_menu () {
version='0.9'
prog="$(echo $(basename $0))"

cat <<EOF
This script is used to manage openvz containers. You can list, create, delete, and set parameters of the virtual machine.
  $prog <[-l|--list] [-lt|--listtemplates] [-c|--create] [-d|--delete] [-s|--set] [-cc|--control] [-dc|--lock] [-sc|--suspend] [-h|--help]>
  Example: $prog -l 102
           $prog -lt
           $prog -c 102 centos-6-x86_64
           $prog -s hostname hostname.domain.com
           $prog --set ipadd 192.168.2.102
           $prog -s nameserver "8.8.8.8 8.8.4.4"
           $prog -cc 102 (start|stop|restart|status)
           $prog --lock 102 {yes|no)
           $prog --suspend 102 (suspend|restore)
           $prog -h

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

  -h|--help)

    help_menu ;;

  *)

    help_menu ;;

esac
