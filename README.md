# Setting Up Kiosk

## OEM Installation of the Operating System

Boot from Ubuntu Desktop 18.04.4 LTS as OEM installation on machine and start the installation. Go through the installation process setting the following details.
- Keyboard layout: Danish
- Minimal installation
- Install third party software: yes
- Timezone: Copenhagen
- Erase disk and install Ubuntu

Do the installation in "next-next-next" style until the installation is ready and the system wants to reboot. When the machine computer has rebooted, connect to a WiFi and run the following command:
```
wget -qO- https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/oem-install.sh | sudo bash
```

Wait until the terminal ask for the password of the user and input it. The machine will reboot and is ready for installation.

## Installation (OOBP)

Wait for the machine to reboot and proceed with the installation. Go through the installation process setting the following details.
Note, that this repo is work in process and these details are for the target environment. This repo will be made more modular and portable later.
- Language: English
- Install third party software: yes
- Timezone: Copenhagen
- Keyboard layout: Danish 
- User information:
  - Name: inlead
  - Computer name: inlead-kiosk-XXX
  - Username: inlead
  - Password: [predefined value]
  - [x] Log in automatically

Do the installation in "next-next-next" style until the installation is ready and the system wants to reboot. When the machine computer has rebooted, run the following command: 
```
wget -qO- https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/master/oobp-install.sh | sudo bash
```

Wait until the terminal says that it's safe to shutdown. Confirm that you would like to shutdown, and from this point on, the computer is ready for production.


## Configuration

In order to configure the computer, the Configuration Manager needs to run (TBD).


# Known issues
Some computers come with a predefined Onboard display output. In the process of installing OEM, you might need to press `Super`+`P` multiple times, until the display you are using becomes active.
