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


### OOBP

echo "$TIMESTAMP # Create user"
sudo su -c "groupadd kiosk"
sudo su -c "useradd kiosk -s /bin/bash -d /home/kiosk/ -m -g kiosk"

echo "$TIMESTAMP # Add users to sudo"
sudo sh -c "echo \"kiosk ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"
sudo sh -c "echo \"inlead ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"

echo "$TIMESTAMP # Patch GNNOME shell extension"
wget -qO- https://gitlab.gnome.org/GNOME/gnome-shell/merge_requests/252.diff |  sudo patch /usr/bin/gnome-shell-extension-tool

echo "$TIMESTAMP # Define autologin"
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



echo "$TIMESTAMP # Create autostart"
sudo -u kiosk mkdir -p /home/kiosk/.config
sudo -u kiosk mkdir -p /home/kiosk/.config/autostart
sudo -u kiosk touch /home/kiosk/.config/gnome-initial-setup-done 

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


echo "$TIMESTAMP # Network policy"
sudo tee /etc/polkit-1/localauthority/50-local.d/10-network-manager.pkla >/dev/null <<'EOF'
[Let user kiosk modify system settings for network]
Identity=unix-user:kiosk
Action=org.freedesktop.NetworkManager.settings.modify.system
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

trap : 0

echo >&2 '
************
*** DONE *** 
************
'

read -p "Do you want to restart? (Yy)" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo reboot
fi
