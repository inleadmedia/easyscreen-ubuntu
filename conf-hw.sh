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

auth_token="$1";
destination="$2";
lms_domain="$3";
branch=$4;
TMID="$5";

echo "$TIMESTAMP # Install FF linux app"
sudo -u kiosk git clone -q -b $branch "git@github.com:inleadmedia/es-linux-apps.git" /home/kiosk/es-linux-apps
sudo -u kiosk bash /home/kiosk/es-linux-apps/installation/install-nvm.sh
sudo -u kiosk bash -c "bash /home/kiosk/es-linux-apps/installation/install-app.sh --auth-token=$auth_token --destination=$destination --lms-domain=$lms_domain --app-branch=$branch --rfid-scanner=FEIG --printer=POS --tmid=$TMID --barcode-scanner=evtest --feig-scanner-app-branch=$branch --printer-app-branch=$branch --barcode-app-branch=$branch"

trap : 0

echo >&2 '
************
*** DONE *** 
************
'
