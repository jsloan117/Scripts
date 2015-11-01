#!/bin/bash
# used to upgrade SickRage/CouchPotato
# Added the new check_directory_exist function to automatically detect the next backup dir number in line

sb_base='/opt'
sb_user='sickbeard'
cp_base='/opt'
cp_user='couchpotato'

check_directory_exist () {
x=1
dir=/data/"$prog"_old

while [[ -d $dir ]]; do

    x=$(( $x + 1 ))
    dir=$dir$x
    [[ -d $dir ]] && dir=$(echo $dir | sed 's|[0-9]||g')

done
export dir
}

upgrade_sickbeard () {
local bdir=$dir
cd $sb_base
service sickbeard stop
mv sickbeard $bdir
git clone https://github.com/sickragetv/sickrage.git
mv sickrage sickbeard
cp -p $bdir/cache.db sickbeard/
cp -p $bdir/failed.db sickbeard/
cp -p $bdir/sickbeard.db sickbeard/
cp -p $bdir/config.ini sickbeard/
cp -Rp $bdir/cache sickbeard/
find ./sickbeard -type f -exec chmod 640 {} \;
find ./sickbeard -type d -exec chmod 750 {} \;
chmod 750 sickbeard/SickBeard.py
chown -R $sb_user.$sb_user sickbeard/
service sickbeard start
}

upgrade_couchpotato () {
local bdir=$dir
cd $cp_base
service couchpotato stop
mv couchpotato $bdir
git clone https://github.com/ruudburger/couchpotatoserver.git
mv couchpotatoserver couchpotato
cp -p $bdir/settings.conf couchpotato/
find ./couchpotato -type f -exec chmod 640 {} \;
find ./couchpotato -type d -exec chmod 750 {} \;
chmod 750 couchpotato/CouchPotato.py
chown -R $cp_user.$cp_user couchpotato/
service couchpotato start
}

prog="$1"
case "$prog" in

    sickbeard)

        check_directory_exist && upgrade_sickbeard ;;

    couchpotato)

        check_directory_exist && upgrade_couchpotato ;;

    *)

        echo -e "\nplease supply either sickbeard or couchpotato to upgrade!\n" && exit 1 ;;

esac
