#!/bin/sh

GTK_THEME=Adwaita
SUCCESSFILE=/home/kiosk/easyscreen-initial-setup-done

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
        echo "# Establishing connection..."
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
                    --button="Check again!gtk-refresh":1 \
                    --buttons-layout=center
                       case $? in
                           1)
                           checkConnection `expr $1 + 1`
                       esac
                    exit
    fi
}

finalizeInstall() {
    # Send information about this device to Inlead

    # Fetch client name
    cat /home/kiosk/client-name.txt | sed 's/^/Client:/' >> /home/kiosk/mail-details.txt
    # Fetch screen name
    cat /home/kiosk/screen-name.txt | sed 's/^/Screen:/' >> /home/kiosk/mail-details.txt
    # Fetch screen URL
    cat /home/kiosk/screen-url.txt | sed 's/^/URL:/' >> /home/kiosk/mail-details.txt
    # Fetch Client IP
    curl --silent --output /home/kiosk/mail-details.txt ifconfig.io | sed 's/^/IP:/' >> /home/kiosk/mail-details.txt
    # Fetch TeamViewer ID
    cat .config/teamviewer/client.conf |grep ClientIDOfTSUser | sed 's/^/TW:/' >> /home/kiosk/mail-details.txt

    mail -s 'New easyScreen device connected' support@inlead.dk -a "From: kiosk@inlead.dk" < /home/kiosk/mail-details.txt

    sleep 1
    reboot
}

if [[ ! -e $SUCCESSFILE ]]; then
    # Check internet connection
    checkConnection "1"
    sleep 2
    sudo -u kiosk wget -q --output-document=/home/kiosk/kiosk-install.sh https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/new-installation/kiosk-install.sh
    sudo chmod +x /home/kiosk/kiosk-install.sh
    sleep 2
	# @TODO This is not error prune atm
    /home/kiosk/kiosk-install.sh | tee -a /home/kiosk/install-log.txt | \
    "${YAD[@]}" --text="$TEXTHEADER\n$TEXT_INSTALL\n" \
                --text-info --tail --back=black --fore=white --fontname="Monospace 10" \
                --align=left \
                --button="gtk-ok":0 --button="Exit" \
                --buttons-layout=end
                
               bar=$?
               [[ $bar -eq 0 ]] && reload

    # @TODO This should only be set if above is successfull

else
    # Check internet connection
    checkConnection "1"
    
    "${YAD[@]}" --text="$TEXTHEADER\n$TEXT_WELCOME\n" \
                --form --align=left \
                --button="gtk-close:1" --button="gtk-ok":0 \
                --buttons-layout=end

               foo=$?
               [[ $foo -eq 1 ]] && exit 0

    # Configuration
    CKEY=$(($RANDOM * $$))

    # Configuration page
    yad \
        --plug=$CKEY --tabnum=1 --form --separator='\n' --quoted-output \
        --field="Displays!preferences-desktop-display":FBTN "gnome-control-center display" \
        --field="Date and Time!preferences-system-time":FBTN "gnome-control-center datetime" \
        --field="Sound!multimedia-volume-control":FBTN "gnome-control-center sound" &

    # Screen setup page
    yad \
        --plug=$CKEY --tabnum=2 --form --separator='\n' --quoted-output \
        --field="Client":FBTN "clients" \
        --field="Screen":FBTN "screens" &

    # Schedule page
    yad \
        --plug=$CKEY --tabnum=3 --form --separator='\n' --quoted-output \
        --date-format="%H %M" \
        --field="Auto-shutdown?":FBTN "sudo schedule" &

    # Hardware
    yad \
        --plug=$CKEY --tabnum=4 --form --separator='\n' --quoted-output \
        --date-format="%H %M" \
        --field="Any hardware needed?":CHK &
        # @TODO This should call conf-hw.sh if checked

    # Main dialog
    "${YAD[@]}" --text="$TEXTHEADER\n$TEXT_CONF\n" \
                --notebook --key=$CKEY --tab="Configuration" --tab="Client" --tab="Schedule" --tab="Hardware" \
                --buttons-layout=center \
                --button="gtk-cancel":0 --button="gtk-apply:1"
                   case $? in
                      1)
                      finalizeInstall
                   esac

fi
exit 0
