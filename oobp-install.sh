#!/bin/bash

### OOBP

# sudo without password
sudo sh -c "echo \"kiosk ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"

# Define autologin
sudoedit /etc/gdm3/custom.conf
  AutomaticLoginEnable=True
  AutomaticLogin=kiosk

# Install FF linux app
sudo wget --output-document=/home/kiosk/install-app.sh http://storage.easyting.dk/ubuntu/install-app.sh && exec bash -c "bash /home/kiosk/install-app.sh 869173763bec469dd2f846e660801c1c4068ecb3 /home/kiosk/es-linux-app https://v3.lms.inlead.ws release"

# Create user and define autologin
sudo adduser kiosk && usermod -aG sudo kiosk && reboot

# Create autostart	
sudo mkdir /home/kiosk/.config/autostart && sudo wget --output-document=/home/kiosk/.config/autostart/kiosk.desktop http://storage.easyting.dk/ubuntu/kiosk.desktop && sudo wget --output-document=/home/kiosk/kiosk.sh http://storage.easyting.dk/ubuntu/kiosk.sh && sudo chmod +x /home/kiosk/kiosk.sh && reboot

