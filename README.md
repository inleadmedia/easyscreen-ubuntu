# Setting Up Kiosk

## Installation

Boot from Ubuntu Desktop 18.04.4 LTS on a machine and start the installation. Go through the installation process setting the following details.
- Keyboard layout: Danish
- Minimal installation
- Install third party software: yes
- Timezone: Copenhagen
- Erase disk and install Ubuntu

Wait for the machine to reboot and proceed with the installation. Go through the installation process setting the following details.

- User information:
  - Name: inlead
  - Computer name: inlead-kiosk-XXX
  - Username: inlead
  - Password: [predefined value]
  - [x] Log in automatically

Do the installation in "next-next-next" style until the installation is ready and the system wants to reboot. When the machine computer has rebooted, connect to a WiFi and run the following command:
```
bash <(wget -O- https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/new-installation/oem-install.sh)
```

Wait until the terminal ask for the password of the user and input it.

Wait until the terminal says that it's safe to shutdown. Confirm that you would like to shutdown, and from this point on, the computer is ready for production.


## Configuration

In order to configure the computer, the Configuration Manager needs to run (TBD).


# Known issues
Some computers come with a predefined Onboard display output. In the process of installing OEM, you might need to press `Super`+`P` multiple times, until the display you are using becomes active.
