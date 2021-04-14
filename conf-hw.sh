#!/bin/bash

## Define user
USER=kiosk
HOMEDIR=/home/${USER}

## Disable term blank
setterm -blank 0

## Define timestamp
TIMESTAMP=`date "+%Y-%m-%d %H:%M:%S"`

## Define colors
BOLD=$(tput bold)
UNDERLINE=$(tput sgr 0 1)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)


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

HWSUCCESSFILE=${HOMEDIR}/hardware-setup-done

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Fix auth token${RESET}"
sudo -u ${USER} mkdir -p ${HOMEDIR}/.ssh
sudo -u ${USER} wget -q --output-document=${HOMEDIR}/.ssh/authtoken http://storage.easyting.dk/ubuntu/authtoken

AUTH_TOKEN=$(cat ${HOMEDIR}/.ssh/authtoken)
DESTINATION="${HOMEDIR}/es-linux-app";
LMS_DOMAIN="https://v3.lms.inlead.dk";
BRANCH=master;
TWID=$(sudo cat /etc/teamviewer/global.conf |grep -oP '(?<=ClientID = )[0-9]+');

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Install FF linux app${RESET}"
sudo -u ${USER} rm -rf ${HOMEDIR}/es-linux-apps ${HOMEDIR}/es-linux-app ${HOMEDIR}/.nvm ${HOMEDIR}/.npm
sudo -u ${USER} git clone -q -b $BRANCH "https://$AUTH_TOKEN@github.com/inleadmedia/es-linux-apps.git" ${HOMEDIR}/es-linux-apps
sudo -u ${USER} bash ${HOMEDIR}/es-linux-apps/installation/install-nvm.sh
sudo -u ${USER} bash -c "bash ${HOMEDIR}/es-linux-apps/installation/install-app.sh --auth-token=$AUTH_TOKEN --destination=$DESTINATION --lms-domain=$LMS_DOMAIN --app-branch=$BRANCH --tmid=$TWID --feig-scanner-app-branch=$BRANCH --printer-app-branch=$BRANCH --barcode-app-branch=$BRANCH $1"

# Add file in order to check for previous installation.
touch $HWSUCCESSFILE

trap : 0

echo >&2 '
************
*** DONE *** 
************
'
