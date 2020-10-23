#!/bin/bash

## Define user
USER=kiosk
HOMEDIR=/home/${USER}
HOMEREPO=https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/bibbox

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

### OEM

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Install and upgrade software${RESET}"
sudo apt-get update || exit 1
sudo apt-get upgrade -y || exit 1

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Install tools and essentials${RESET}"
sudo apt-get install unclutter xdotool openssh-server libnotify4 dconf-tools xclip build-essential curl build-essential libssl-dev git yad jq -y || exit 1
 
# @TODO This should be done quietly without prompt.
sudo debconf-set-selections <<< "postfix postfix/mailname string easyscreen-display"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'" 
sudo apt-get install mailutils -y || exit 1
sudo sed -i 's/inet_protocols = all/inet_protocols = ipv4/g' /etc/postfix/main.cf
sudo service postfix restart
sudo wget -q ${HOMEREPO}/reload -P /usr/bin/ && sudo chmod +x /usr/bin/reload
sudo wget -q ${HOMEREPO}/schedule -P /usr/bin/ && sudo chmod +x /usr/bin/schedule
sudo wget -q ${HOMEREPO}/clients -P /usr/bin/ && sudo chmod +x /usr/bin/clients
sudo wget -q ${HOMEREPO}/screens -P /usr/bin/ && sudo chmod +x /usr/bin/screens
sudo wget -q ${HOMEREPO}/hardware -P /usr/bin/ && sudo chmod +x /usr/bin/hardware

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# See Hidden Startup Applications${RESET}"
sudo sed -i 's/NoDisplay=true/NoDisplay=false/g' /etc/xdg/autostart/*.desktop

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Remove autostart items${RESET}"
sudo rm -f /etc/xdg/autostart/update-notifier 2> /dev/null
sudo rm -f /etx/xdg/autostart/orca 2> /dev/null

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Delete Firefox${RESET}"
sudo apt-get purge firefox -y || exit 1

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Install Chrome${RESET}"
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c "echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list.d/google-chrome.list"
sudo apt-get update || exit 1
sudo apt-get install google-chrome-stable -y || exit 1

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Install and configure TeamViewer${RESET}"
sudo wget -q https://download.teamviewer.com/download/linux/version_13x/teamviewer-host_amd64.deb
sudo apt-get install -y ./teamviewer-host_amd64.deb -y --allow-downgrades || exit 1
sudo teamviewer --passwd 4MenFromMars
sudo teamviewer --daemon stop
sudo tee -a /opt/teamviewer/config/global.conf >/dev/null <<'EOF'
[int32] Always_Online = 1
[int32] EulaAccepted = 1
[int32] EulaAcceptedRevision = 6
EOF

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Disable screen tearing${RESET}"
sudo tee -a /usr/share/X11/xorg.conf.d/20-intel.conf >/dev/null <<'EOF'
Section "Device"
   Identifier "Intel Graphics"
   Driver "intel"
   Option "AccelMethod" "sna"
   Option "TearFree" "true"
   Option "DRI" "3"
EndSection
EOF

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Disable Appport${RESET}"
sudo systemctl disable apport
sudo tee -a /etc/default/apport >/dev/null <<'EOF'
# set this to 0 to disable apport, or to 1 to enable it
# you can temporarily override this with
# sudo service apport start force_start=1
enabled=0
EOF

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Fetch custom background${RESET}"
sudo wget -q https://storage.easyting.dk/ubuntu/inlead-ff-ubuntu-bg.png -P /usr/share/backgrounds/

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Make GRUB quiet and fast${RESET}"
sudo tee -a /etc/default/grub >/dev/null <<'EOF'
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=true
EOF
sudo update-grub

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Set GNOME settings${RESET}"
wget -q -O - ${HOMEREPO}/dconf.sh | sudo bash


### OOBP

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Install and upgrade software${RESET}"
sudo apt-get update || exit 1
sudo apt-get upgrade -y || exit 1

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Create user${RESET}"
sudo su -c "groupadd ${USER}"
sudo su -c "useradd ${USER} -s /bin/bash -d ${HOMEDIR}/ -m -g ${USER}"

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Add users to sudo${RESET}"
sudo sh -c "echo \"${USER} ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"
sudo sh -c "echo \"inlead ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Patch GNNOME shell extension${RESET}"
wget -qO- https://gitlab.gnome.org/GNOME/gnome-shell/merge_requests/252.diff |  sudo patch -f /usr/bin/gnome-shell-extension-tool

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Define autologin${RESET}"
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

sudo -u ${USER} tee ${HOMEDIR}/.dmrc >/dev/null <<'EOF'
[Desktop]
Session=kiosk
EOF


echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Network policy${RESET}"
sudo tee /etc/polkit-1/localauthority/50-local.d/10-network-manager.pkla >/dev/null <<'EOF'
[Let user kiosk modify system settings for network]
Identity=unix-user:kiosk
Action=org.freedesktop.NetworkManager.settings.modify.system
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Disable upgrades alltogether${RESET}"
sudo sed -i 's/Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades
sudo apt-get remove ubuntu-release-upgrader-core -y || exit 1

echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Create autostart${RESET}"
sudo -u ${USER} mkdir -p ${HOMEDIR}/.config
sudo -u ${USER} mkdir -p ${HOMEDIR}/.config/autostart
sudo -u ${USER} touch ${HOMEDIR}/.config/gnome-initial-setup-done 
sudo -u ${USER} tee ${HOMEDIR}/.config/autostart/conf.desktop >/dev/null <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Configuration Manager
Exec=/bin/bash /home/kiosk/conf.sh
X-GNOME-Autostart-enabled=true
EOF

sleep 1
sudo -u ${USER} wget -q --output-document=${HOMEDIR}/conf.sh ${HOMEREPO}/conf.sh
sudo -u ${USER} chmod +x ${HOMEDIR}/conf.sh
sleep 2


echo "${GREEN}${TIMESTAMP} ${UNDERLINE}# Cleanup${RESET}"
## Find the dir.
cd ~/
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
rm -rf ${DIR}/{Desktop,Downloads,Documents,Music,Pictures,Public,Templates,Videos
sudo apt-get autoremove -y || exit 1
sudo -u kiosk rm -rf ${HOMEDIR}/{Desktop,Downloads,Documents,Music,Pictures,Public,Templates,Videos

trap : 0

echo >&2 '
************
*** DONE *** 
************
'

sleep 3
clear

echo "Are you sure you want to poweroff [y/n]"
while true; do
	read yn
    case $yn in
        [Yy]* ) sudo poweroff;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
