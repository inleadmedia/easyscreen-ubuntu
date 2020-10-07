#!/bin/bash

abort()
{
    echo >&2 '
***************
*** ABORTED ***
***************
'
    echo "An error occurred. Exiting..." >&2
    exit 1
}

trap 'abort' 0

set -e

TIMESTAMP=`date "+%Y-%m-%d %H:%M:%S"`

echo "$TIMESTAMP # Fix auth token"
sudo mkdir -p /home/kiosk/.ssh
sudo wget -q --output-document=/home/kiosk/.ssh/authtoken http://storage.easyting.dk/ubuntu/authtoken

auth_token=$(cat /home/kiosk/.ssh/authtoken)
destination="/home/kiosk/es-linux-app";
lms_domain="https://lms.inlead.ws";
branch=master;
TWID=$(cat /home/kiosk/.config/teamviewer/client.conf |grep -oP '(?<=ClientIDOfTSUser = )[0-9]+' |sed 's/^/TW: /');

echo "$TIMESTAMP # Install FF linux app"
sudo git clone -q -b $branch "https://$auth_token@github.com/inleadmedia/es-linux-apps.git" /home/kiosk/es-linux-apps
sudo bash /home/kiosk/es-linux-apps/installation/install-nvm.sh
sudo bash -c "bash /home/kiosk/es-linux-apps/installation/install-app.sh --auth-token=$auth_token --destination=$destination --lms-domain=$lms_domain --app-branch=$branch --tmid=$TWID --feig-scanner-app-branch=$branch --printer-app-branch=$branch --barcode-app-branch=$branch $CONCATENATE"

trap : 0

echo >&2 '
************
*** DONE *** 
************
'
