#!/bin/bash

### OEM

# Install and upgrade software
sudo apt-get update -y
sudo apt-get upgrade -y

# Install tools and essentials
sudo apt-get install unclutter --yes
sudo apt-get install xdotool --yes
sudo apt-get install openssh-server --yes
sudo apt-get install libnotify4 --yes
sudo apt-get install dconf-tools --yes
sudo apt-get install xclip --yes
sudo apt-get install build-essential --yes
sudo apt-get install curl --yes
sudo apt-get install build-essential --yes
sudo apt-get install libssl-dev --yes

# Install nodejs stuff
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash;
source ~/.bashrc

# Delete Firefox
sudo apt-get purge firefox -y

# Install Chrome
sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb --yes

# Install TeamViewer
sudo wget https://download.teamviewer.com/download/linux/version_13x/teamviewer-host_amd64.deb
sudo apt install ./teamviewer-host_amd64.deb --yes

# Disable built in gestures
sudo wget -qO- https://gitlab.gnome.org/GNOME/gnome-shell/merge_requests/252.diff | patch /usr/bin/gnome-shell-extension-tool
wget "https://extensions.gnome.org/extension-data/disable-gestures%40mattbell.com.au.v2.shell-extension.zip"
gnome-shell-extension-tool -i disable-gestures@mattbell.com.au.*.zip
gnome-shell-extension-tool -e disable-gestures@mattbell.com.au

# Disable screen tearing 
sudo wget --output-document=/usr/share/X11/xorg.conf.d/20-intel.conf http://storage.easyting.dk/ubuntu/20-intel.conf

# Disable Appport
sudo systemctl disable apport
cat <<EOF | sudo tee /etc/default/apport
# set this to 0 to disable apport, or to 1 to enable it
# you can temporarily override this with
# sudo service apport start force_start=1
enabled=0
EOF


# Fetch custom background
sudo wget https://storage.easyting.dk/ubuntu/inlead-ff-ubuntu-bg.png -P /usr/share/backgrounds/

# Set GNOME settings
cat <<EOF | sudo tee /etc/dconf/profile/user
user-db:user
system-db:local
EOF

sudo mkdir -p /etc/dconf/db/local.d

cat <<EOF | sudo tee  /etc/dconf/db/local.d/00_session
[org/gnome/desktop/session]
idle-delay='0'
EOF

cat <<EOF | sudo tee  /etc/dconf/db/local.d/01_lockdown
[org/gnome/desktop/lockdown]
disable-lock-screen=true
EOF

cat <<EOF | sudo tee  /etc/dconf/db/local.d/02_screensaver
[org/gnome/desktop/screensaver]
idle-activation-enabled=false
lock-enabled=false
picture-uri='file:///usr/share/backgrounds/inlead-ff-ubuntu-bg.png'
EOF

cat <<EOF | sudo tee  /etc/dconf/db/local.d/03_interface
[org/gnome/desktop/interface]
clock-show-date=true
enable-animations=false
EOF

cat <<EOF | sudo tee  /etc/dconf/db/local.d/04_datetime
[org/gnome/desktop/datetime]
automatic-timezone=true
EOF

cat <<EOF | sudo tee  /etc/dconf/db/local.d/05_background
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/inlead-ff-ubuntu-bg.png'
show-desktop-icons=false
EOF

cat <<EOF | sudo tee  /etc/dconf/db/local.d/06_nm-applet
[org/gnome/nm-applet]
disable-disconnected-notifications=true
disable-connected-notifications=true
disable-vpn-notifications=true
disable-wifi-create=true
suppress-wireless-networks-available=true
EOF

cat <<EOF | sudo tee  /etc/dconf/db/local.d/07_notifications
[org/gnome/desktop/notifications]
show-banners=true
show-in-lock-screen=true
EOF

cat <<EOF | sudo tee  /etc/dconf/db/local.d/08_power
[org/gnome/settings-daemon/plugins/power]
idle-dim=false
active=false
EOF

cat <<EOF | sudo tee  /etc/dconf/db/local.d/09_updates
[org/gnome/settings-daemon/plugins/updates]
frequency-updates-notification=0
EOF

cat <<EOF | sudo tee  /etc/dconf/db/local.d/10_notifier
[com/ubuntu/update-notifier]
no-show-notifications=true
EOF

cat <<EOF | sudo tee  /etc/dconf/db/local.d/11_software
[org/gnome/software]
download-updates=false
allow-updates=false
EOF

# Lock settings
sudo mkdir -p /etc/dconf/db/local.d/locks

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/00_idle-delay
/org/gnome/desktop/session/idle-delay
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/01_disable-lock-scree
/org/gnome/desktop/lockdown/disable-lock-screen
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/02_idle-activation-enabled
/org/gnome/desktop/screensaver/idle-activation-enabled
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/02_lock-enabled
/org/gnome/desktop/screensaver/lock-enabled
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/03_s-picture-uri
/org/gnome/desktop/screensaver/picture-uri
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/04_clock-show-date
/org/gnome/desktop/interface/clock-show-date
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/05_enable-animations
/org/gnome/desktop/interface/enable-animations
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/06_automatic-timezone
/org/gnome/desktop/datetime/automatic-timezone
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/07_bg-picture-uri
/org/gnome/desktop/background/picture-uri
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/08_show-desktop-icons
/org/gnome/desktop/background/show-desktop-icons
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/09_disable-disconnected-notifications
/org/gnome/nm-applet/disable-disconnected-notifications
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/10_disable-connected-notifications
/org/gnome/nm-applet/disable-connected-notifications
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/11_disable-vpn-notifications
/org/gnome/nm-applet/disable-vpn-notifications
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/12_disable-wifi-create
/org/gnome/nm-applet/disable-wifi-create
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/13_suppress-wireless-networks-available
/org/gnome/nm-applet/suppress-wireless-networks-available
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/14_show-banners
/org/gnome/desktop/notifications/show-banners
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/15_show-in-lock-screen
/org/gnome/desktop/notifications/show-in-lock-screen
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/16_idle-dim
/org/gnome/settings-daemon/plugins/power/idle-dim
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/16_active
/org/gnome/settings-daemon/plugins/power/active
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/17_frequency-updates-notification
/org/gnome/settings-daemon/plugins/updates/frequency-updates-notification
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/18_no-show-notifications
/com/ubuntu/update-notifier/no-show-notifications
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/19_download-updates
/org/gnome/software/download-updates
EOF

cat <<EOF | sudo tee /etc/dconf/db/local.d/locks/20_allow-updates
/org/gnome/software/allow-updates
EOF

sudo dconf update

# Remove tearing
#sudo sh -c "echo \"CLUTTER_PAINT=disable-clipped-redraws:disable-culling\" >> /etc/environment"
#sudo sh -c "echo \"CLUTTER_VBLANK=True\" >> /etc/environment"

# Install and upgrade software
sudo apt-get update -y
sudo apt-get upgrade -y

# Adjust GRUB to start faster
#sudoedit /etc/default/grub && sudo update-grub && systemctl reboot -i
#  GRUB_DEFAULT=Ubuntu
#  GRUB_HIDDEN_TIMEOUT=0
#  GRUB_HIDDEN_TIMEOUT_QUIET=true
#  GRUB_TIMEOUT=0.1
#  GRUB_DISABLE_OS_PROBER=true
#  GRUB_SAVE_DEFAULT=false

# All done
echo "All done."

oem-config-prepare --quiet
sudo poweroff
