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

# Restart TW
sudo teamviewer daemon restart
sleep 3s

### KIOSK

echo "$TIMESTAMP # Disable Gestures"
wget -q "https://extensions.gnome.org/extension-data/disable-gestures%40mattbell.com.au.v2.shell-extension.zip"
sudo -u kiosk gnome-shell-extension-tool -i disable-gestures@mattbell.com.au.v2.shell-extension.zip

echo "$TIMESTAMP # Disable OSK"
wget -q "https://extensions.gnome.org/extension-data/On_Screen_Keyboard_Button%40bradan.eu.v4.shell-extension.zip"
sudo -u kiosk gnome-shell-extension-tool -i On_Screen_Keyboard_Button@bradan.eu.v4.shell-extension.zip

wget -q "https://extensions.gnome.org/extension-data/cariboublocker%40git.keringar.xyz.v1.shell-extension.zip"
sudo -u kiosk gnome-shell-extension-tool -i cariboublocker@git.keringar.xyz.v1.shell-extension.zip

echo "$TIMESTAMP # ALL DONE - please click OK"

trap : 0

echo >&2 '
************
*** DONE *** 
************
'
sudo -u kiosk touch /home/kiosk/easyscreen-initial-setup-done
