#!/bin/bash
# used to upgrade SickRage/CouchPotato/SABnzbd
# Version: 1.3

sb_path='/opt/sickbeard'
sb_base=$(dirname $sb_path)
sb_user='sickbeard'
cp_path='/opt/couchpotato'
cp_base=$(dirname $cp_path)
cp_user='couchpotato'
sn_path='/opt/sabnzbd'
sn_base=$(dirname $sn_path)
sn_user='sabnzbd'
backup_prefix='_old'

check_directory_exist () {
x=1

if [[ $prog = sickbeard ]]; then

  dir=$sb_path$backup_prefix

elif [[ $prog = couchpotato ]]; then

  dir=$cp_path$backup_prefix

elif [[ $prog = sabnzbd ]]; then

  dir=$sn_path$backup_prefix

fi

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
#git clone https://github.com/sickragetv/sickrage.git # Old SR
git clone https://github.com/SickRage/SickRage.git # New SR
mv SickRage sickbeard
#cp -p $bdir/cache.db sickbeard/
cp -p $bdir/failed.db sickbeard/
cp -p $bdir/sickbeard.db sickbeard/
cp -p $bdir/config.ini sickbeard/
cp -Rp $bdir/cache sickbeard/
find $sb_path -type f -exec chmod 640 {} \;
find $sb_path -type d -exec chmod 750 {} \;
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
find $cp_path -type f -exec chmod 640 {} \;
find $cp_path -type d -exec chmod 750 {} \;
chmod 750 couchpotato/CouchPotato.py
chown -R $cp_user.$cp_user couchpotato/
service couchpotato start
}

upgrade_sabnzbd () {
# sn_version assumes sabnzbd is still in the 0.7.XX branch
# sabnzbd_url assumes the same type url pattern. example: http://domain.com/path/to/file/if/there/is/one/filename.tar.gz/download

check_for_new_version () {
wget -q --spider http://sourceforge.net/projects/sabnzbdplus/files/sabnzbdplus/$sn_new_version/SABnzbd-$sn_new_version-src.tar.gz/download
}

local sabnzbd_url="$1"
local sabnzbdurl="${sabnzbd_url%/*}"
local sabnzbd_file="${sabnzbdurl##*/}"
local sabnzbd_changelog_file="$sn_path/CHANGELOG.txt"
local sn_version=$(head -n2 $sabnzbd_changelog_file | tail -n1 | awk '{ print $1 }' | awk -F'.' '{ print $3 }')
local next_version=$(( $sn_version + 1 ))
local sn_new_version="0.7.$next_version"
local bdir=$dir

if [[ -z $sabnzbd_url ]]; then

  if [[ $(check_for_new_version; echo $?) -ne 0 ]]; then

    echo -e "\nWe are not able to automatically upgrade SABnzbd. There is no new version: $sn_new_version detected, if this is a mistake, you should be able to pass the url as the second argument to get it to work. \n" && exit 5

  fi

fi

cd $sn_base
service sabnzbd stop
mv sabnzbd $bdir

if [[ -z $sabnzbd_url ]]; then

  wget -O SABnzbd-$sn_new_version-src.tar.gz http://sourceforge.net/projects/sabnzbdplus/files/sabnzbdplus/$sn_new_version/SABnzbd-$sn_new_version-src.tar.gz/download
  tar -xaf SABnzbd-$sn_new_version-src.tar.gz

else

  wget -O $sabnzbd_file $sabnzbd_url
  tar -xaf $sabnzbd_file
  rm -f $sabnzbd_file

fi

mv SABnzbd* sabnzbd
cp -p $bdir/config.ini sabnzbd/
find $sn_path -type f -exec chmod 640 {} \;
find $sn_path -type d -exec chmod 750 {} \;
chmod 750 sabnzbd/SABnzbd.py
chown -R $sn_user.$sn_user sabnzbd/
service sabnzbd start
}

prog="$1"
case "$prog" in

    sickbeard)

        check_directory_exist && upgrade_sickbeard ;;

    couchpotato)

        check_directory_exist && upgrade_couchpotato ;;

    sabnzbd)

        shift
        check_directory_exist && upgrade_sabnzbd "$1" ;;

    *)

        echo -e "\nEx: $0 [sickbeard|couchpotato|sabnzbd] \n" && exit 1 ;;

esac
