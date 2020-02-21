#!/bin/bash
auth_token="$1";
destination="$2";
lms_domain="$3";
branch=$4;
TMID="$5";

### OOBP

# Get SSH keys
sudo mkdir -p /root/.ssh
sudo wget -q --output-document=/root/.ssh/id_rsa.pub http://storage.easyting.dk/ubuntu/sshkey1.txt
sudo wget -q --output-document=/root/.ssh/id_rsa http://storage.easyting.dk/ubuntu/sshkey2.txt
sudo chmod 0600 /root/.ssh/id_rsa

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

# Create user
sudo su -c "groupadd kiosk"
sudo su -c "useradd kiosk -s /bin/bash -d /home/kiosk/ -m -g kiosk"

# Add users to sudo
sudo sh -c "echo \"kiosk ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"
sudo sh -c "echo \"inlead ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"

# Define autologin

cat <<EOF | sudo tee /etc/gdm3/custom.conf 
# GDM configuration storage
#
# See /usr/share/gdm/gdm.schemas for a list of available options.

[daemon]
AutomaticLoginEnable=true
AutomaticLogin=kiosk

# Uncoment the line below to force the login screen to use Xorg
#WaylandEnable=false

# Enabling automatic login

# Enabling timed login
TimedLoginEnable = true
TimedLogin = username
TimedLoginDelay = 10

[security]

[xdmcp]

[chooser]

[debug]
# Uncomment the line below to turn on debugging
# More verbose logs
# Additionally lets the X server dump core if it crashes
#Enable=true
EOF

sudo bash -c 'cat > /usr/share/lightdm/lightdm.conf.d/99-kiosk.conf' << EOF
[Seat:*]
user-session=kiosk
EOF

sudo -u kiosk bash -c 'cat > ~kiosk/.dmrc' << EOF
[Desktop]
Session=kiosk
EOF

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
sudo git clone -q -b $branch "git@github.com:inleadmedia/es-linux-apps.git" /home/kiosk/es-linux-apps
sudo bash /home/kiosk/es-linux-apps/installation/install-nvm.sh
sudo bash -c "bash /home/kiosk/es-linux-apps/installation/install-app.sh --auth-token=$auth_token --destination=$destination --lms-domain=$lms_domain --app-branch=$branch --rfid-scanner=FEIG --printer=POS --tmid=$TMID --barcode-scanner=serialport"

reboot

