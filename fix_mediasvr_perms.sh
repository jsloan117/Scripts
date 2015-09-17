#!/bin/sh
# Fixes the permissions and ownership settings on my transmission/plex media server setup

PATH=/sbin:/bin:/usr/sbin:/usr/bin
mediadir=/data/plexmediaserver
mediadir2=/backup/plexmediaserver
torrentsdir=/backup/torrents

# Fixes ownership issues
chown -R plex:media $mediadir $mediadir2
chown -R transmission:media $torrentsdir
chmod 755 /backup

# Removes junk type files
find $mediadir/{movies,tvshows} -type f \( -iname "*.txt" -o -iname "*.nfo*" -o -iname "*.ignore" -o -iname "*.db" -o -iname "*.nzb" -o -iname "*.part" -o -iname "*.added" -o -iname "*.jpg" -o -iname "*.png" \) -exec rm -rf {} \;
find $torrentsdir/downloaded -type f \( -iname "*.txt" -o -iname "*.nfo*" -o -iname "*.ignore" -o -iname "*.db" -o -iname "*.nzb" -o -iname "*.added" \) -exec rm -rf {} \;
find $mediadir2/{movies,tvshows} -type f \( -iname "*.txt" -o -iname "*.nfo*" -o -iname "*.ignore" -o -iname "*.db" -o -iname "*.nzb" -o -iname "*.part" -o -iname "*.added" -o -iname "*.jpg" -o -iname "*.png" \) -exec rm -rf {} \;

# Fixes permissions on the masses
find $mediadir/{movies,tvshows} -type f -exec chmod 640 {} \;
find $mediadir/{movies,tvshows} -type d -exec chmod 770 {} \;
find $mediadir2/{movies,tvshows} -type f -exec chmod 640 {} \;
find $mediadir2/{movies,tvshows} -type d -exec chmod 770 {} \;

# Fixes permissions on main directories
chmod 770 $mediadir $mediadir2 $torrentsdir
#chmod 770 $mediadir/{movies,music,tvshows}
chmod 770 $torrentsdir/{downloading,downloaded}

exit 0
