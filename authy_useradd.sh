#===============================================================================================
# Name:         authy_useradd.sh
# By:           Jonathan M. Sloan <jsloan@macksarchive.com>
# Date:         07-21-2015
# Purpose:      Enable's a user of choice to be protected via authy two factor authentication
# Version:      1.4
# Info:         Will automatically prompt for user's email address, country-code, phone-number
#===============================================================================================
# ChangeLog: Cleaned up the check_exist function, and will exit w/ status code 1 if user exists.
# Added new "isValidPhoneNum" function to ensure user enters the correct format for number.

set -e

AUTHY=$(which authy-ssh)
prog=$(echo ${AUTHY##*/})
bin_base=$(echo ${AUTHY%/*})
protect_user="$1"

if [[ ! -x $AUTHY ]]; then

   echo -e "\n$AUTHY was not found on your system! \n" && exit 1

fi

print_usage () {
echo -e "\nUsage: $0 { username } Ex: $0 root \n"
}

isValidPhoneNum () {
case $1 in

    "" | *[!0-9-]* | *[!0-9])

        return 1 ;;

esac

local IFS='-'
set -- $1

[[ $# -eq 3 ]] && [[ ${#1} -eq 3 ]] && [[ ${#2} -eq 3 ]] && [[ ${#3} -eq 4 ]]
}

check_exist () {
local chkuser=$1
local userexistmessage="User: '%s' already protected by authy \n"

if grep -w ^user $bin_base/authy-ssh.conf | awk -F"=" '{ print $2 }' | awk -F":" '{ print $1 }' | grep -wq $chkuser; then

   printf "$userexistmessage" "$chkuser" && exit 1

fi
}

if [[ "$#" -ne '1' ]]; then

   print_usage && exit 1

fi

check_exist "$protect_user"

echo ""
read -ep "Please enter your Email Address: " a_email
read -ep "Please enter your Country-code: " a_ccode
read -ep "Please enter your (include the dashes) Cell Phone Number: " a_phone

if isValidPhoneNum $a_phone; then

    a_phone=${a_phone}

else

    echo -e "\nThe number $a_phone is not correct. Ex: 123-456-7890 \n" && exit 1

fi
echo ""

$AUTHY enable $protect_user $a_email $a_ccode $a_phone
exit 0
