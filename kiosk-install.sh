#!/bin/bash
#set -x
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>/tmp/kiosk-install.out 2>&1
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

echo "$TIMESTAMP # Create autostart"
sudo -u kiosk tee /home/kiosk/.config/autostart/kiosk.desktop >/dev/null <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Kiosk
Exec=/home/kiosk/kiosk.sh
X-GNOME-Autostart-enabled=true
EOF

sudo -u kiosk wget -q --output-document=/home/kiosk/kiosk.sh https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/new-installation/kiosk.sh
sudo chmod +x /home/kiosk/kiosk.sh

sudo -u kiosk rm -rf /home/kiosk/.config/autostart/conf.desktop

echo "$TIMESTAMP # ALL DONE - please click OK"

trap : 0

echo >&2 '
************
*** DONE *** 
************
'
echo "$TIMESTAMP # Create SUCCESSFILE"
sudo -u kiosk touch /home/kiosk/easyscreen-initial-setup-done
#set +x
