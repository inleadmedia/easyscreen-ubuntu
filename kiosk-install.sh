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

### KIOSK

echo "$TIMESTAMP # Disable Gestures"
wget -q "https://extensions.gnome.org/extension-data/disable-gestures%40mattbell.com.au.v2.shell-extension.zip"
sudo -u kiosk gnome-shell-extension-tool -i disable-gestures@mattbell.com.au.v2.shell-extension.zip
sudo -u kiosk gnome-shell-extension-tool -e disable-gestures@mattbell.com.au

echo "$TIMESTAMP # Disable OSK"
wget -q "https://extensions.gnome.org/extension-data/On_Screen_Keyboard_Button%40bradan.eu.v4.shell-extension.zip"
sudo -u kiosk gnome-shell-extension-tool -i On_Screen_Keyboard_Button@bradan.eu.v4.shell-extension.zip
sudo -u kiosk gnome-shell-extension-tool -e On_Screen_Keyboard_Button@bradan.eu

echo "$TIMESTAMP # Fix SSH keys"
sudo -u kiosk mkdir -p /home/kiosk/.ssh
sudo -u kiosk wget -q --output-document=/home/kiosk/.ssh/id_rsa.pub http://storage.easyting.dk/ubuntu/sshkey1.txt
sudo -u kiosk wget -q --output-document=/home/kiosk/.ssh/id_rsa http://storage.easyting.dk/ubuntu/sshkey2.txt
chmod 0600 /home/kiosk/.ssh/id_rsa

sudo -u kiosk tee /home/kiosk/.ssh/config >/dev/null <<'EOF'
Host *
    UpdateHostKeys yes
    StrictHostKeyChecking accept-new
EOF

echo "$TIMESTAMP # Install FF linux app"
sudo -u kiosk git clone -q -b $branch "git@github.com:inleadmedia/es-linux-apps.git" /home/kiosk/es-linux-apps
sudo -u kiosk bash /home/kiosk/es-linux-apps/installation/install-nvm.sh
sudo -u kiosk bash -c "bash /home/kiosk/es-linux-apps/installation/install-app.sh --auth-token=$auth_token --destination=$destination --lms-domain=$lms_domain --app-branch=$branch --rfid-scanner=FEIG --printer=POS --tmid=$TMID --barcode-scanner=serialport"

#reboot


trap : 0

echo >&2 '
************
*** DONE *** 
************
'