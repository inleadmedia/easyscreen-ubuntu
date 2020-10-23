#!/bin/bash

### DCONF

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


## Lock the settings.
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
