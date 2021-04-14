#!/bin/bash

## Define user
USER=kiosk
HOMEDIR=/home/${USER}
HOMEREPO=https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/bibbox


GTK_THEME=Adwaita
SUCCESSFILE=${HOMEDIR}/easyscreen-initial-setup-done

YAD=(
    yad \
        --title=$TITLE --width=400 --height=300 --align=left --center \
        --skip-taskbar --borders=10 --no-escape --always-print-result --splash --text-align=center
)

TEXTHEADER="<span size='x-large' font_weight='bold'>Configuration Manager</span>\n"

TEXT_WELCOME="Welcome to the configuration process of easyScreen.\nYou will need to configure your device in order to finish your installation.\n\nThis should not take more than 3 minutes.\n\nPlease press OK when you are ready to start.\n\nWhen you finish, the computer will restart and is ready."
TEXT_INTERNET="Checking your current internet connection, please wait..."
TEXT_NOCONN="It seems like you are not connected to the internet.\n\nPlease configure your Wi-Fi or Cable in order to proceed:"
TEXT_CONF="Configure your display, date and sound settings of the computer and proceed with selecting your Library and the Screen that you would like to display on this device."
TEXT_INSTALL="This is the first time you run the Configuration Manager.\n\nWe will do some adjustments before you can proceed, hang on for a few seconds and press OK.."

checkConnection() {
    (
        /usr/bin/wget -q --tries=10 --timeout=5 http://www.google.com -O /tmp/index.google &> /dev/null
        echo "# Checking internet connection...\n"
        sleep 2
    ) |
    "${YAD[@]}" --text="$TEXTHEADER\n$TEXT_INTERNET\n" \
                --progress --auto-close --pulsate \
                --no-buttons

    if [ ! -s /tmp/index.google ];then
        NKEY=$(($RANDOM * $$))

        yad \
            --plug=$NKEY --tabnum=1 --form --separator='\n' --quoted-output \
            --field="Wi-Fi!network-wireless":FBTN "gnome-control-center wifi" \
            --field="Cable!network-workgroup":FBTN "gnome-control-center network" &

        "${YAD[@]}" --text="$TEXTHEADER\n$TEXT_NOCONN\n" \
                    --notebook --key=$NKEY --tab="Network" \
                    --button="Check again!gtk-refresh:1" \
                    --buttons-layout=center
                       case $? in
                           1)
                           checkConnection `expr $1 + 1`
                       esac
    fi
}

finalizeInstall() {
    # Create autostart
    sudo -u ${USER} tee ${HOMEDIR}/.config/autostart/kiosk.desktop >/dev/null <<'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Kiosk
Exec=/home/kiosk/kiosk.sh
X-GNOME-Autostart-enabled=true
EOF

    sudo -u ${USER} wget -q --output-document=${HOMEDIR}/kiosk.sh ${HOMEREPO}/kiosk.sh
    sudo chmod +x ${HOMEDIR}/kiosk.sh

    sudo -u ${USER} rm -rf ${HOMEDIR}/.config/autostart/conf.desktop

    # Send information about this device to Inlead
    touch ${HOMEDIR}/mail-details.txt
    # Fetch client name
    cat ${HOMEDIR}/client-name.txt | sed 's/^/Client: /' >> ${HOMEDIR}/mail-details.txt
    # Fetch screen name
    cat ${HOMEDIR}/screen-name.txt | sed 's/^/Screen: /' >> ${HOMEDIR}/mail-details.txt
    # Fetch screen URL
    cat ${HOMEDIR}/screen-url.txt | sed 's/^/URL: /' >> ${HOMEDIR}/mail-details.txt
    # Fetch Client IP
    curl --silent --output ${HOMEDIR}/ip-details.txt ifconfig.io
    cat ${HOMEDIR}/ip-details.txt | sed 's/^/IP: /' >> ${HOMEDIR}/mail-details.txt
    # Fetch TeamViewer ID
    sudo cat /etc/teamviewer/global.conf |grep -oP '(?<=ClientID = )[0-9]+' |sed 's/^/TW: /' >> ${HOMEDIR}/mail-details.txt

    mail -s 'New easyScreen device connected' support@inlead.dk -a "From: kiosk@inlead.dk" < ${HOMEDIR}/mail-details.txt

    touch $SUCCESSFILE

    sleep 2
    reboot
}

if [[ ! -e $SUCCESSFILE ]]; then
    # Check internet connection
    checkConnection "1"
    sleep 1

    sudo -u ${USER} wget -q --output-document=${HOMEDIR}/kiosk-install.sh ${HOMEREPO}/kiosk-install.sh
    sudo chmod +x ${HOMEDIR}/kiosk-install.sh
    sleep 1

    ${HOMEDIR}/kiosk-install.sh | tee -a ${HOMEDIR}/install-log.txt | \
    "${YAD[@]}" --text="$TEXTHEADER\n$TEXT_INSTALL\n" \
                --text-info --tail --back=black --fore=white --fontname="Monospace 9" \
                --align=left \
                --button="Exit" --button="gtk-ok:0" \
                --buttons-layout=end
                
               bar=$?
               [[ $bar -eq 0 ]] && reload

    # @TODO Exit button should restart the computer.

else
    # Check internet connection
    checkConnection "1"
    
    "${YAD[@]}" --text="$TEXTHEADER\n$TEXT_WELCOME\n" \
                --form --align=left \
                --button="gtk-close:1" --button="gtk-ok:0" \
                --buttons-layout=end

               foo=$?
               [[ $foo -eq 1 ]] && exit 0
    
    # @TODO Exit button should restart the computer.

    # OS configuration tab
    CKEY=$(($RANDOM * $$))
    yad \
        --plug=$CKEY --tabnum=1 --form --separator='\n' --quoted-output \
        --field="Displays!preferences-desktop-display":FBTN "gnome-control-center display" \
        --field="Date and Time!preferences-system-time":FBTN "gnome-control-center datetime" \
        --field="Sound!multimedia-volume-control":FBTN "gnome-control-center sound" &

    # Client and Screen setup tab
    yad \
        --plug=$CKEY --tabnum=2 --form --separator='\n' --quoted-output \
        --field="Library":FBTN "clients" \
        --field="Screen":FBTN "screens" &

    # Schedule tab
    yad \
        --plug=$CKEY --tabnum=3 --form --separator='\n' --quoted-output \
        --date-format="%H %M" \
        --field="Auto-shutdown?":FBTN "sudo schedule" &

    # Hardware tab
    yad \
        --plug=$CKEY --tabnum=4 --form --separator='\n' --quoted-output \
        --field="Click to setup hardware":FBTN "hardware" &

    # Main dialog
    "${YAD[@]}" --text="$TEXTHEADER\n$TEXT_CONF\n" \
                --notebook --key=$CKEY --tab="Configuration" --tab="Screen" --tab="Schedule" --tab="Extra" \
                --buttons-layout=center \
                --button="gtk-cancel:0" --button="gtk-apply:1"
                   case $? in
                      1)
                      finalizeInstall
                   esac

fi
exit 0
