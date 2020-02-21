#!/bin/bash

### OOBP

# Create user and define autologin
sudo useradd -s /bin/bash -d /home/kiosk/ -m kiosk

# sudo without password
#sudo adduser kiosk
#usermod -aG sudo kiosk
#reboot
#sudo sh -c "echo \"kiosk ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"

# Define autologin
echo 'AutomaticLoginEnable=True' >> /etc/gdm3/custom.conf
echo 'AutomaticLogin=kiosk' >> /etc/gdm3/custom.conf

# Install FF linux app
sudo wget --output-document=/home/kiosk/install-app.sh https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/install-app.sh
sudo exec bash -c "bash /home/kiosk/install-app.sh c84c0799e0d67cb7feabc699b0b5812607e8935a /home/kiosk/es-linux-apps https://v3.lms.inlead.ws release"

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

