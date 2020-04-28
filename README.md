# Architecture Overview
## Introduction

## Specifications

# Setting Up Kiosk

## OEM Installation of the Operating System

Boot from Ubuntu Desktop 18.04.4 LTS as OEM installation on machine and start the installation. Go through the installation process setting the following details.
- Keyboard layout: Danish
- Minimal installation
- Install third party software: yes
- Timezone: Copenhagen
- Erase disk and install Ubuntu

Do the installation in "next-next-next" style until the installation is ready and the system wants to reboot. When the machine computer has rebooted, run the following command. 
```
wget -qO- https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/oem-install.sh | sudo bash
```

Wait until the terminal ask for the password of the user and input it. The machine will shutdown and is ready for install.

## Installation

Power on the machine and proceed with the installation. Go through the installation process setting the following details. Note, that this repo is work in process and these details are for the target environment. This repo will be made more modular and portable later.
- Language: English
- Install third party software: yes
- Timezone: Copenhagen
- Keyboard layout: Danish 
- User information:
  - Name: inlead
  - Computer name: inlead-kiosk-XXX
  - Username: inlead
  - Password: [predefined value]

Do the installation in "next-next-next" style until the installation is ready and the system wants to reboot. When the machine computer has rebooted, run the following command. 
```
wget -qO- https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/oobp-install.sh | sudo bash
```

Wait until the terminal says that it's safe to reboot. Now reboot and from that boot on, the computer should match the current description.

## Prepration

When the machine computer has rebooted, run the following command. 
```
wget -qO- https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/kiosk-install.sh | sudo bash -s [AUTH_TOKEN] /home/kiosk/es-linux-app https://v3.lms.inlead.ws develop 123456789
```

Wait until the terminal says that it's safe to reboot. Now reboot and from that boot on, the computer is ready for production.


## Configuration

Temporarily, you will have to.
* Edit `/home/kiosk/kiosk.sh#L50` with the proper URL to spawn in Chrome
* Gather TeamViewer information
  * Settings -> Security -> Personal password -> [Change passsword] -> XXX -> [Apply]
  * Gather the "Your ID"

