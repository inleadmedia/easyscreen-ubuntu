#!/bin/bash
auth_token="$1";
destination="$2";
lms_domain="$3";
branch=$4;
TMID="$5";

### OOBP

echo "# Create user"
sudo su -c "groupadd kiosk"
sudo su -c "useradd kiosk -s /bin/bash -d /home/kiosk/ -m -g kiosk"

echo "# Add users to sudo"
sudo sh -c "echo \"kiosk ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"
sudo sh -c "echo \"inlead ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"

echo "# Patch GNNOME shell extension"
wget -qO- https://gitlab.gnome.org/GNOME/gnome-shell/merge_requests/252.diff |  sudo patch /usr/bin/gnome-shell-extension-tool

echo "# Disable built in gestures"
wget -q "https://extensions.gnome.org/extension-data/disable-gestures%40mattbell.com.au.v2.shell-extension.zip"
sudo -u kiosk gnome-shell-extension-tool -i disable-gestures@mattbell.com.au.v2.shell-extension.zip
sudo -u kiosk gnome-shell-extension-tool -e disable-gestures@mattbell.com.au

echo "# Disable OSK"
wget -q "https://extensions.gnome.org/extension-data/On_Screen_Keyboard_Button%40bradan.eu.v4.shell-extension.zip"
sudo -u kiosk gnome-shell-extension-tool -i On_Screen_Keyboard_Button@bradan.eu.v4.shell-extension.zip
sudo -u kiosk gnome-shell-extension-tool -e On_Screen_Keyboard_Button@bradan.eu

echo "# Define autologin"
sudo tee /etc/gdm3/custom.conf >/dev/null <<'EOF'
# GDM configuration storage

[daemon]
AutomaticLoginEnable=true
AutomaticLogin=kiosk
InitialSetupEnable=false

TimedLoginEnable = true
TimedLogin = username
TimedLoginDelay = 10

[security]

[xdmcp]

[chooser]

[debug]
#Enable=true
EOF

sudo tee /usr/share/lightdm/lightdm.conf.d/99-kiosk.conf >/dev/null <<'EOF'
[Seat:*]
user-session=kiosk
EOF

sudo -u kiosk tee ~kiosk/.dmrc >/dev/null <<'EOF'
[Desktop]
Session=kiosk
EOF

echo "# Create autostart"
sudo -u kiosk mkdir -p /home/kiosk/.config
sudo -u kiosk mkdir -p /home/kiosk/.config/autostart

sudo -u kiosk tee /home/kiosk/.config/autostart/kiosk.desktop >/dev/null <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Kiosk
Exec=/home/kiosk/kiosk.sh
X-GNOME-Autostart-enabled=true
EOF

sudo -u kiosk wget -q --output-document=/home/kiosk/kiosk.sh https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/kiosk.sh
sudo chmod +x /home/kiosk/kiosk.sh

# Install FF linux app

echo "# Get SSH keys"
sudo -u kiosk mkdir -p /home/kiosk/.ssh
sudo -u kiosk wget -q --output-document=/home/kiosk/.ssh/id_rsa.pub http://storage.easyting.dk/ubuntu/sshkey1.txt
sudo -u kiosk wget -q --output-document=/home/kiosk/.ssh/id_rsa http://storage.easyting.dk/ubuntu/sshkey2.txt
chmod 0600 /home/kiosk/.ssh/id_rsa

sudo -u kiosk git clone -q -b $branch "git@github.com:inleadmedia/es-linux-apps.git" /home/kiosk/es-linux-apps
sudo -u kiosk bash /home/kiosk/es-linux-apps/installation/install-nvm.sh
sudo -u kiosk bash -c "bash /home/kiosk/es-linux-apps/installation/install-app.sh --auth-token=$auth_token --destination=$destination --lms-domain=$lms_domain --app-branch=$branch --rfid-scanner=FEIG --printer=POS --tmid=$TMID --barcode-scanner=serialport"

#reboot
