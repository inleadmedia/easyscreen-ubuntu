# Setting Up Kiosk

## Installation

Boot from Ubuntu Desktop 18.04 LTS on a machine and start the installation. Go through the installation process setting the following details.
- **Welcome**
  - English
- **Keyboard layout**
  - Danish | Danish
- **Wireless**
  - [x] I don't want to cnnnect to a wi-fi network right now.
- **Updates and other software**
  - [ ] Normal installation
  - [x] Minimal installation
  - [ ] Download updates while installing
  - [x] Install third party software
- **Installation type**
  - [x] Erase disk and install Ubuntu
  - Confirm "Write the changes to the disk?"
- **Where are you from**
  - Copenhagen
- **Who are you?**
  - Your name: inlead
  - Your computer's name: inlead-kiosk-XXX
  - Pick a username: inlead
  - Choose a password: [predefined value]
  - Confirm your password: [predefined value]
  - [x] Log in automatically

Do the installation in "next-next-next" style until the installation is completed and the system wants to reboot. When the machine computer has rebooted, connect to a WiFi and run the following command:
```
bash <(wget -O- https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/bibbox/install.sh)
```

Wait until the terminal ask for the password of the user and input it.

Wait until the terminal says that it's safe to shutdown. Confirm that you would like to shutdown (Y), and from this point on, the computer is ready for production.


## Configuration

In order to configure the computer, the Configuration Manager needs to run (TBD).

![Install](/conf-manager/conf-install.jpg)
![No connection](/conf-manager/conf-noconnection.jpg)
![Screen](/conf-manager/conf-screen.jpg)
![Shutdown](/conf-manager/conf-shutdown.jpg)
![Shutdown - select](/conf-manager/conf-shutdown-select.jpg)
![Start](/conf-manager/conf-start.jpg)
![Configuration](/conf-manager/conf.jpg)


# Known issues
Some computers come with a predefined Onboard display output. In the process of installing OEM, you might need to press `Super`+`P` multiple times, until the display you are using becomes active.
