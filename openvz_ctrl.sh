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
local OSTEMPLATE="$2"
local CONFDEFAULT="$3"
[[ -z "$CONFDEFAULT" ]] && CONFDEFAULT='basic'

vzctl create "$CTID" --ostemplate "$OSTEMPLATE" -–config "$CONFDEFAULT"
}

delete_vz_container () {
local CTID="$1"

control_container "$CTID" "stop"
control_container "$CTID" "destroy"
}

set_vz_parameters () {
local CTID="$1"
local parameter="$2" # hostname, ipadd, nameserver, onboot, userpasswd
local data="$3" # Value

if [[ "$parameter" = 'name' ]]; then

    vzctl set "$CTID" --name "$data" --save
    [[ ! -L /etc/vz/names/"$data" ]] && ln -vs ln -vs ../../../etc/vz/conf/"$CTID".conf /etc/vz/names/"$data"

else

    vzctl set "$CTID" --"$parameter" "$data" --save

fi
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

    control_container "$CTID" "stop"
#    vzctl set "$CTID" --disabled yes --save
    set_vz_parameters "$CTID" "disabled" "yes"

elif [[ "$action" = 'no' ]]; then

    set_vz_parameters "$CTID" "disabled" "no"
#    vzctl set "$CTID" --disabled no --save
    control_container "$CTID" "start"
    control_container "$CTID" "status"

fi
}

suspend_container () {
local CTID="$1"
local action="$2"

if [[ "$action" = 'suspend' ]]; then

    vzctl suspend "$CTID" --dumpfile /vz/dump/"$CTID".dump

elif [[ "$action" = 'restore' ]]; then

    vzctl resume "$CTID" --dumpfile /vz/dump/"$CTID".dump

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
