#!/bin/bash

### OOBP

# sudo without password
sudo sh -c "echo \"kiosk ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"

# Define autologin
sudoedit /etc/gdm3/custom.conf
  AutomaticLoginEnable=True
  AutomaticLogin=kiosk

# Install FF linux app
sudo wget --output-document=/home/kiosk/install-app.sh http://storage.easyting.dk/ubuntu/install-app.sh
exec bash -c "bash /home/kiosk/install-app.sh 869173763bec469dd2f846e660801c1c4068ecb3 /home/kiosk/es-linux-app https://v3.lms.inlead.ws release"

# Create user and define autologin
sudo adduser kiosk
usermod -aG sudo kiosk
reboot

# Create autostart	
sudo mkdir /home/kiosk/.config/autostart
cat <<EOF | sudo tee /home/kiosk/.config/autostart/kiosk.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Kiosk
Exec=/home/kiosk/kiosk.sh
X-GNOME-Autostart-enabled=true
EOF

sudo wget --output-document=/home/kiosk/kiosk.sh https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/kiosk.sh
sudo chmod +x /home/kiosk/kiosk.sh
reboot

