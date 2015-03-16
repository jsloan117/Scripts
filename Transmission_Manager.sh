#!/bin/bash
#======================================================================================================================================================================================================
# Name:                 transmission_manager.sh
# By:                   Jonathan M. Sloan <jsloan@macksarchive.com>
# Date:                 03-15-2015
# Purpose:              Used to manage torrents in transmission
# Version:              1.0
#=====================================================================================================================================================================================================

# Path to transmission-remote
TR="/usr/bin/transmission-remote"

remove_finished_torrents () { # Remove finished torrents
local LIST=$($TR -l | tail -n+2 | grep Finished | awk '{ print $1; }')
for ID in $LIST; do

  local NAME="$($TR -t $ID -i | grep Name:)"
  echo "$ID: ${NAME#*Name: }"

  $TR -t $ID -r >/dev/null 2>&1

done
}

active_torrents () { # Shows active and ideling torrents in transmision
local HEADER=$($TR -l | head -n1)
local ACTIVE_NUM=$($TR -l | tail -n+2 | grep -vE "100%|Stopped|Idle" | grep -v "^Sum\:" | wc -l)
local ACTIVE=$($TR -l | tail -n+2 | grep -vE "100%|Stopped|Idle" | grep -v "^Sum\:" | sort -nrk2)
local SUM=$($TR -l | tail -n+2 | grep -vE "100%|Stopped|Idle" | grep -w "^Sum\:")
local IDLE_NUM=$($TR -l | tail -n+2 | grep "Idle" | grep -v "^Sum\:" | wc -l)
local IDLE=$($TR -l | tail -n+2 | grep "Idle" | grep -v "^Sum\:")

printf "There is %d active torrent currently within Transmission\n\n" "$ACTIVE_NUM"
printf "%s\n\n" "$HEADER"
printf "%s\n\n" "$ACTIVE"
printf "%s\n\n" "$SUM"
printf "There is %d ideling torrents currently within Transmission\n\n" "$IDLE_NUM"
printf "%s\n\n" "$HEADER"
printf "%s\n\n" "$IDLE"
}

finished_torrents () { # Shows the finished torrents in transmission
local HEADER=$($TR -l | head -n1)
local FINISHED_NUM=$($TR -l | tail -n+2 | grep "Finished" | grep -v "^Sum\:" | wc -l)
local FINISHED=$($TR -l | tail -n+2 | grep "Finished" | grep -v "^Sum\:")

printf "There is %d finished torrents currently within Transmission\n\n" "$FINISHED_NUM"
printf "%s\n\n" "$HEADER"
printf "%s\n\n" "$FINISHED"
}

add_new_torrent () { # Add new torrents from the command line
local torrents="$@"

for torrent in "$torrents"; do

  $TR --trash-torrent -a $torrent

done
}

verify_torrents () { # Verify torrents
local LIST=$($TR -l | tail -n+2 | grep -v "^Sum\:" | awk '{ print $1; }')

for ID in $LIST; do

  local NAME="$($TR -t $ID -i | grep Name:)"
  echo -e "$ID: ${NAME#*Name: }"

done

echo ""
read -ep "Please enter torrent ID number " TOR_ID
[[ -z "$TOR_ID" ]] && echo -e "\nYou must supply a torrent ID\n" && exit
$TR -t $TOR_ID -v
}

torrent_information () { # Check torrent information
local LIST=$($TR -l | tail -n+2 | grep -v "^Sum\:" | awk '{ print $1; }')

for ID in $LIST; do

  local NAME="$($TR -t $ID -i | grep Name:)"
  echo -e "$ID: ${NAME#*Name: }"

done

echo ""
read -ep "Please enter torrent ID number " TOR_ID
[[ -z "$TOR_ID" ]] && echo -e "\nYou must supply a torrent ID\n" && exit
$TR -t $TOR_ID -i
}

session_info () {
$TR -si
}

session_stats () {
$TR -st
}

help_menu () {
version='1.0'
prog="$(echo $(basename $0))"

cat <<EOF
This script is used to manage transmission daemon. You can add/remove/verify torrents, check out session related info, list torrents.

  $prog <[-r|--remove] [-a|--active] [-f|--finished] [-add|--new] [-v|--verify] [-i|--info] -si [-ss|--stats]>
  version: $version

EOF
}

var="$1"
case $var in

  -r|--remove)

    remove_finished_torrents ;;

  -a|--active)

    active_torrents ;;

  -f|--finished)

    finished_torrents ;;

  -add|--new)

    shift
    add_new_torrent $@ ;;

  -v|--verify)

    verify_torrents ;;

  -i|--info)

    torrent_information ;;

  -si)

    session_info ;;

  -ss|--stats)

    session_stats ;;

  -h|--help)

    help_menu ;;

  *)

    echo "No Input" && exit 1 ;;

esac