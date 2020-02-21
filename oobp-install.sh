#!/bin/bash
auth_token="$1";
destination="$2";
lms_domain="$3";
branch=$4;
TMID="$5";

### OOBP

# Get SSH keys
sudo wget -q --output-document=~/.ssh/id_rsa.pub http://storage.easyting.dk/ubuntu/sshkey1.txt
sudo wget -q --output-document=~/.ssh/id_rsa http://storage.easyting.dk/ubuntu/sshkey2.txt
sudo chmod 0600 ~/.ssh/id_rsa

# Patch gnome shell
sudo wget -qO- https://gitlab.gnome.org/GNOME/gnome-shell/merge_requests/252.diff | patch /usr/bin/gnome-shell-extension-tool

# Disable built in gestures
sudo wget -q "https://extensions.gnome.org/extension-data/disable-gestures%40mattbell.com.au.v2.shell-extension.zip"
sudo gnome-shell-extension-tool -i disable-gestures@mattbell.com.au.v2.shell-extension.zip
sudo gnome-shell-extension-tool -e disable-gestures@mattbell.com.au

# Disable OSK
sudo wget -q "https://extensions.gnome.org/extension-data/On_Screen_Keyboard_Button%40bradan.eu.v4.shell-extension.zip"
sudo gnome-shell-extension-tool -i On_Screen_Keyboard_Button@bradan.eu.v4.shell-extension.zip
sudo gnome-shell-extension-tool -e On_Screen_Keyboard_Button@bradan.eu

# Create user and define autologin
sudo useradd -s /bin/bash -d /home/kiosk/ -m kiosk

# Define autologin
echo 'AutomaticLoginEnable=True' >> /etc/gdm3/custom.conf
echo 'AutomaticLogin=kiosk' >> /etc/gdm3/custom.conf

# Create autostart	
sudo mkdir -p /home/kiosk/.config
sudo mkdir -p /home/kiosk/.config/autostart

cat <<EOF | sudo tee /home/kiosk/.config/autostart/kiosk.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Kiosk
Exec=/home/kiosk/kiosk.sh
X-GNOME-Autostart-enabled=true
EOF

sudo wget -q --output-document=/home/kiosk/kiosk.sh https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/kiosk.sh
sudo chmod +x /home/kiosk/kiosk.sh

# Install FF linux app
sudo git clone -b $branch "git@github.com/inleadmedia/es-linux-apps.git" /home/kiosk/es-linux-apps
sudo bash /home/kiosk/es-linux-apps/installation/install-nvm.sh
sudo bash -c "bash /home/kiosk/es-linux-apps/installation/install-app.sh --auth-token=$auth_token --destination=$destination --lms-domain=$lms_domain --app-branch=$branch --rfid-scanner=FEIG --printer=POS --tmid=$TMID --barcode-scanner=serialport"

reboot

