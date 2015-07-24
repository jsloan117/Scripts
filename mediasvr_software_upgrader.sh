#!/bin/bash
# Used to upgrade SickRage/Couchpotato from git repo
# Please fill in the below varibles correctly. 
# NOTE: YOU MAY NEED TO ADJUST THE PERMISSIONS ON THE FIND COMMAND BELOW!!

SB_BASE='/opt'
SB_USER='sickbeard'
CP_BASE='/opt'
CP_USER='couchpotato'

upgrade_sickbeard () {
cd $SB_BASE
service sickbeard stop
mv sickbeard sickbeard_old
git clone https://github.com/SiCKRAGETV/SickRage.git
mv SickRage sickbeard
cp -p sickbeard_old/cache.db sickbeard/
cp -p sickbeard_old/failed.db sickbeard/
cp -p sickbeard_old/sickbeard.db sickbeard/
cp -p sickbeard_old/config.ini sickbeard/
cp -Rp sickbeard_old/cache sickbeard/
find ./sickbeard -type f -exec chmod 640 {} \;
find ./sickbeard -type d -exec chmod 750 {} \;
chmod 750 sickbeard/SickBeard.py
chown -R $SB_USER.$SB_USER sickbeard/
service sickbeard start
}

upgrade_couchpotato () {
cd $CP_BASE
service couchpotato stop
mv couchpotato couchpotato_old
git clone https://github.com/RuudBurger/CouchPotatoServer.git
mv CouchPotatoServer couchpotato
cp -p couchpotato_old/settings.conf couchpotato/
find ./couchpotato -type f -exec chmod 640 {} \;
find ./couchpotato -type d -exec chmod 750 {} \;
chmod 750 couchpotato/CouchPotato.py
chown -R $CP_USER.$CP_USER couchpotato/
service couchpotato start
}

case "$1" in

    sickbeard)

        upgrade_sickbeard ;;

    couchpotato)

        upgrade_couchpotato ;;

    *)

        echo -e "\nPlease supply either sickbeard or couchpotato to upgrade!\n" && exit 1 ;;

esac
exit 0
