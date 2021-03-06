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


### OEM

# $TIMESTAMP # Use main mirror"
sudo sed -i 's|http://us.|http://|g' /etc/apt/sources.list
#sudo sed -i -e 's/http:\/\/us.archive/mirror:\/\/mirrors/' -e 's/\/ubuntu\//\/mirrors.txt/' /etc/apt/sources.list

echo "$TIMESTAMP # Install and upgrade software"
sudo apt-get update -qq
sudo apt-get upgrade -qq

echo "$TIMESTAMP # Install tools and essentials"
sudo apt-get install unclutter -qq
sudo apt-get install xdotool -qq
sudo apt-get install openssh-server -qq
sudo apt-get install libnotify4 -qq
sudo apt-get install dconf-tools -qq
sudo apt-get install xclip -qq
sudo apt-get install build-essential -qq
sudo apt-get install curl -qq
sudo apt-get install build-essential -qq
sudo apt-get install libssl-dev -qq
sudo apt-get install git -qq
sudo apt-get install yad -qq
sudo apt-get install jq -qq

 # @TODO This should be done quietly without prompt.
sudo debconf-set-selections <<< "postfix postfix/mailname string easyscreen-display"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'" 
sudo apt-get install mailutils -qq
sudo sed -i 's/inet_protocols = all/inet_protocols = ipv4/g' /etc/postfix/main.cf
sudo service postfix restart
sudo wget -q https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/reload -P /usr/bin/ && sudo chmod +x /usr/bin/reload
sudo wget -q https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/schedule -P /usr/bin/ && sudo chmod +x /usr/bin/schedule
sudo wget -q https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/clients -P /usr/bin/ && sudo chmod +x /usr/bin/clients
sudo wget -q https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/screens -P /usr/bin/ && sudo chmod +x /usr/bin/screens
sudo wget -q https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/hardware -P /usr/bin/ && sudo chmod +x /usr/bin/hardware

echo "$TIMESTAMP # See Hidden Startup Applications"
sudo sed -i 's/NoDisplay=true/NoDisplay=false/g' /etc/xdg/autostart/*.desktop

echo "$TIMESTAMP # Remove autostart items"
sudo rm -f /etc/xdg/autostart/update-notifier 2> /dev/null
sudo rm -f /etx/xdg/autostart/orca 2> /dev/null

echo "$TIMESTAMP # Delete Firefox"
sudo apt-get purge firefox -qq

echo "$TIMESTAMP # Install Chrome"
sudo wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb -qq

echo "$TIMESTAMP # Install TeamViewer"
sudo wget -q https://download.teamviewer.com/download/linux/version_13x/teamviewer-host_amd64.deb
sudo apt install -y ./teamviewer-host_amd64.deb -qq
sudo teamviewer --passwd 4MenFromMars
sudo teamviewer --daemon stop
sudo tee -a /opt/teamviewer/config/global.conf >/dev/null <<'EOF'
[int32] Always_Online = 1
[int32] EulaAccepted = 1
[int32] EulaAcceptedRevision = 6
EOF

echo "$TIMESTAMP # Disable screen tearing"
sudo tee -a /usr/share/X11/xorg.conf.d/20-intel.conf >/dev/null <<'EOF'
Section "Device"
   Identifier "Intel Graphics"
   Driver "intel"
   Option "AccelMethod" "sna"
   Option "TearFree" "true"
   Option "DRI" "3"
EndSection
EOF

echo "$TIMESTAMP # Disable Appport"
sudo systemctl disable apport
sudo tee -a /etc/default/apport >/dev/null <<'EOF'
# set this to 0 to disable apport, or to 1 to enable it
# you can temporarily override this with
# sudo service apport start force_start=1
enabled=0
EOF

echo "$TIMESTAMP # Fetch custom background"
sudo wget -q https://storage.easyting.dk/ubuntu/inlead-ff-ubuntu-bg.png -P /usr/share/backgrounds/

echo "$TIMESTAMP # Make GRUB quiet and fast"
sudo tee -a /etc/default/grub >/dev/null <<'EOF'
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=true
EOF
sudo update-grub

echo "$TIMESTAMP # Set GNOME settings"
sudo tee -a /etc/dconf/profile/user >/dev/null <<'EOF'
user-db:user
system-db:local
EOF

sudo mkdir -p /etc/dconf/db/local.d

sudo tee /etc/dconf/db/local.d/00_session >/dev/null <<'EOF'
[org/gnome/desktop/session]
idle-delay=uint32 0
EOF

sudo tee /etc/dconf/db/local.d/01_lockdown >/dev/null <<'EOF'
[org/gnome/desktop/lockdown]
disable-lock-screen=true
EOF

sudo tee /etc/dconf/db/local.d/02_screensaver >/dev/null <<'EOF'
[org/gnome/desktop/screensaver]
idle-activation-enabled=false
lock-enabled=false
picture-uri='file:///usr/share/backgrounds/inlead-ff-ubuntu-bg.png'
EOF

sudo tee /etc/dconf/db/local.d/03_interface >/dev/null <<'EOF'
[org/gnome/desktop/interface]
clock-show-date=true
enable-animations=false
EOF

sudo tee /etc/dconf/db/local.d/04_datetime >/dev/null <<'EOF'
[org/gnome/desktop/datetime]
automatic-timezone=true
EOF

sudo tee /etc/dconf/db/local.d/05_background >/dev/null <<'EOF'
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/inlead-ff-ubuntu-bg.png'
show-desktop-icons=false
EOF

sudo tee /etc/dconf/db/local.d/06_nm-applet >/dev/null <<'EOF'
[org/gnome/nm-applet]
disable-disconnected-notifications=true
disable-connected-notifications=true
disable-vpn-notifications=true
disable-wifi-create=true
suppress-wireless-networks-available=true
EOF

sudo tee /etc/dconf/db/local.d/07_notifications >/dev/null <<'EOF'
[org/gnome/desktop/notifications]
show-banners=true
show-in-lock-screen=true
EOF

sudo tee /etc/dconf/db/local.d/08_power >/dev/null <<'EOF'
[org/gnome/settings-daemon/plugins/power]
idle-dim=false
active=false
sleep-inactive-battery-timeout=0
sleep-inactive-ac-timeout=0
EOF

sudo tee /etc/dconf/db/local.d/09_updates >/dev/null <<'EOF'
[org/gnome/settings-daemon/plugins/updates]
frequency-updates-notification=0
EOF

sudo tee /etc/dconf/db/local.d/10_notifier >/dev/null <<'EOF'
[com/ubuntu/update-notifier]
no-show-notifications=true
EOF

sudo tee /etc/dconf/db/local.d/11_software >/dev/null <<'EOF'
[org/gnome/software]
download-updates=false
allow-updates=false
EOF

sudo tee /etc/dconf/db/local.d/12_keyboard >/dev/null <<'EOF'
[org/gnome/desktop/a11y/applications]
screen-keyboard-enabled=false
EOF

echo "$TIMESTAMP # Lock dconf settings"
sudo mkdir -p /etc/dconf/db/local.d/locks

sudo tee /etc/dconf/db/local.d/locks/00_idle-delay >/dev/null <<'EOF'
/org/gnome/desktop/session/idle-delay
EOF

sudo tee /etc/dconf/db/local.d/locks/01_disable-lock-screen >/dev/null <<'EOF'
/org/gnome/desktop/lockdown/disable-lock-screen
EOF

sudo tee /etc/dconf/db/local.d/locks/02_idle-activation-enabled >/dev/null <<'EOF'
/org/gnome/desktop/screensaver/idle-activation-enabled
EOF

sudo tee /etc/dconf/db/local.d/locks/02_lock-enabled >/dev/null <<'EOF'
/org/gnome/desktop/screensaver/lock-enabled
EOF

sudo tee /etc/dconf/db/local.d/locks/03_s-picture-uri >/dev/null <<'EOF'
/org/gnome/desktop/screensaver/picture-uri
EOF

sudo tee /etc/dconf/db/local.d/locks/04_clock-show-date >/dev/null <<'EOF'
/org/gnome/desktop/interface/clock-show-date
EOF

sudo tee /etc/dconf/db/local.d/locks/05_enable-animations >/dev/null <<'EOF'
/org/gnome/desktop/interface/enable-animations
EOF

sudo tee /etc/dconf/db/local.d/locks/06_automatic-timezone >/dev/null <<'EOF'
/org/gnome/desktop/datetime/automatic-timezone
EOF

sudo tee /etc/dconf/db/local.d/locks/07_bg-picture-uri >/dev/null <<'EOF'
/org/gnome/desktop/background/picture-uri
EOF

sudo tee /etc/dconf/db/local.d/locks/08_show-desktop-icons >/dev/null <<'EOF'
/org/gnome/desktop/background/show-desktop-icons
EOF

sudo tee /etc/dconf/db/local.d/locks/09_disable-disconnected-notifications >/dev/null <<'EOF'
/org/gnome/nm-applet/disable-disconnected-notifications
EOF

sudo tee /etc/dconf/db/local.d/locks/10_disable-connected-notifications >/dev/null <<'EOF'
/org/gnome/nm-applet/disable-connected-notifications
EOF

sudo tee /etc/dconf/db/local.d/locks/11_disable-vpn-notifications >/dev/null <<'EOF'
/org/gnome/nm-applet/disable-vpn-notifications
EOF

sudo tee /etc/dconf/db/local.d/locks/12_disable-wifi-create >/dev/null <<'EOF'
/org/gnome/nm-applet/disable-wifi-create
EOF

sudo tee /etc/dconf/db/local.d/locks/13_suppress-wireless-networks-available >/dev/null <<'EOF'
/org/gnome/nm-applet/suppress-wireless-networks-available
EOF

sudo tee /etc/dconf/db/local.d/locks/14_show-banners >/dev/null <<'EOF'
/org/gnome/desktop/notifications/show-banners
EOF

sudo tee /etc/dconf/db/local.d/locks/15_show-in-lock-screen >/dev/null <<'EOF'
/org/gnome/desktop/notifications/show-in-lock-screen
EOF

sudo tee /etc/dconf/db/local.d/locks/16_idle-dim >/dev/null <<'EOF'
/org/gnome/settings-daemon/plugins/power/idle-dim
EOF

sudo tee /etc/dconf/db/local.d/locks/16_active >/dev/null <<'EOF'
/org/gnome/settings-daemon/plugins/power/active
EOF

sudo tee /etc/dconf/db/local.d/locks/17_frequency-updates-notification >/dev/null <<'EOF'
/org/gnome/settings-daemon/plugins/updates/frequency-updates-notification
EOF

sudo tee /etc/dconf/db/local.d/locks/18_no-show-notifications >/dev/null <<'EOF'
/com/ubuntu/update-notifier/no-show-notifications
EOF

sudo tee /etc/dconf/db/local.d/locks/19_download-updates >/dev/null <<'EOF'
/org/gnome/software/download-updates
EOF

sudo tee /etc/dconf/db/local.d/locks/20_allow-updates >/dev/null <<'EOF'
/org/gnome/software/allow-updates
EOF

sudo tee /etc/dconf/db/local.d/locks/21_keyboard >/dev/null <<'EOF'
/org/gnome/desktop/a11y/applications/screen-keyboard-enabled
EOF

sudo tee /etc/dconf/db/local.d/locks/22_sleep-bat >/dev/null <<'EOF'
/org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-timeout
EOF

sudo tee /etc/dconf/db/local.d/locks/23_sleep-ac >/dev/null <<'EOF'
/org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout
EOF

sudo dconf update

# Remove tearing
#sudo sh -c "echo \"CLUTTER_PAINT=disable-clipped-redraws:disable-culling\" >> /etc/environment"
#sudo sh -c "echo \"CLUTTER_VBLANK=True\" >> /etc/environment"


### OOBP

echo "$TIMESTAMP # Install and upgrade software"
sudo apt-get update -qq
sudo apt-get upgrade -qq

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


echo "$TIMESTAMP # Network policy"
sudo tee /etc/polkit-1/localauthority/50-local.d/10-network-manager.pkla >/dev/null <<'EOF'
[Let user kiosk modify system settings for network]
Identity=unix-user:kiosk
Action=org.freedesktop.NetworkManager.settings.modify.system
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

echo "$TIMESTAMP # Disable upgrades alltogether"
sudo sed -i 's/Prompt=.*/Prompt=never/' /etc/update-manager/release-upgrades
sudo apt-get remove ubuntu-release-upgrader-core -qq

echo "$TIMESTAMP # Create autostart"
sudo -u kiosk mkdir -p /home/kiosk/.config
sudo -u kiosk mkdir -p /home/kiosk/.config/autostart
sudo -u kiosk touch /home/kiosk/.config/gnome-initial-setup-done 
sudo -u kiosk tee /home/kiosk/.config/autostart/conf.desktop >/dev/null <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Configuration Manager
Exec=/bin/bash /home/kiosk/conf.sh
X-GNOME-Autostart-enabled=true
EOF

sleep 2
sudo -u kiosk wget -q --output-document=/home/kiosk/conf.sh https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/conf.sh
sudo -u kiosk chmod +x /home/kiosk/conf.sh
sleep 3

trap : 0

echo >&2 '
************
*** DONE *** 
************
'

sleep 5
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
