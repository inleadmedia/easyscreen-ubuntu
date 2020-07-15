
#!/bin/sh
GTK_THEME=Adwaita
SUCCESSFILE=/home/kiosk/easyscreen-initial-setup-done

YAD=(
    yad \
        --title=$TITLE --width=400 --height=300 --align=left --center \
        --skip-taskbar --borders=10 --no-escape --always-print-result --splash --text-align=center
)
TEXTHEADER="<span size='x-large' font_weight='bold'>Configuration Manager</span>\n"

TEXT_WELCOME="Welcome to the configuration process of easyScreen.\nWe are going through a 6-step procecure to finish your installation.\n\nThis should not take more than 3 minutes.\n\nPlease press the button below when you are ready to start."
TEXT_INTERNET="Checking your current internet connection, please wait..."
TEXT_NOCONN="It seems like you are not connected to the internet.\n\nPlease configure your Wi-Fi or Cable in order to proceed:"
TEXT_CONF="Configure your display, date and sound settings as preferred before proceeding:"
TEXT_INSTALL="This is the first time you run the Configuration Manager. We will do some installments before you can proceed. \nGive us a few minutes, and we'll restart the computer for you.."

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
     # Send TeamViewer ID to Inlead
     curl --silent --output /home/kiosk/conf.txt ifconfig.io && cat .config/teamviewer/client.conf |grep ClientIDOfTSUser >> /home/kiosk/conf.txt
     sleep 2
     mail -s 'New ES Device' support@inlead.dk < /home/kiosk/conf.txt
     
     # @TODO do stuff with values from yad form
     
     sleep 1
     reboot
}

if [[ ! -e $SUCCESSFILE ]]; then
    # Check internet connection
    checkConnection "1"

    sudo -u kiosk wget -q --output-document=/home/kiosk/kiosk-install.sh https://raw.githubusercontent.com/inleadmedia/easyscreen-ubuntu/new-installation/kiosk-install.sh
    sudo chmod +x /home/kiosk/kiosk-install.sh
    
    # @TODO This is not error prune atm
    /home/kiosk/kiosk-install.sh | \
    "${YAD[@]}" --text="$TEXTHEADER\n$TEXT_INSTALL\n" \
                --text-info --tail --back=black --fore=white --fontname="Monospace 10" > /home/kiosk/installlog.txt \
                --align=left \
                --button="gtk-ok":0 \
				--button="Exit": \
                --buttons-layout=end
                
               bar=$?
               [[ $bar -eq 0 ]] && reload

    # @TODO This should only be set if above is successfull
    touch $SUCCESSFILE

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
    # @TODO This is supposed to be fetched from the internet
    clients=$(echo "herbib!bronbib!slagbib!tysbib!berbib")
    screens=$(echo "Indgang v. receptionen!Børneafdelingen!Voksen, krimi! Voksen, auditorium!Voksen 4")

    yad \
        --plug=$CKEY --tabnum=2 --form --separator='\n' --quoted-output \
        --field="Client":CB "$clients" \
        --field="Screen":CB "$screens" &
        # @TODO This should set URL in kiosk.sh

    # Schedule page
    yad \
        --plug=$CKEY --tabnum=3 --form --separator='\n' --quoted-output \
        --date-format="%H %M" \
        --field="Auto-shutdown?":CHK \
        --field="Shutdown":CB \
        --field="Startup":CB "19:00!19:30!20:00!20:30!21:00!21:30!22:00!22:30!23:00!23:30!00:00!00:30!01:00!01:30!02:00" "05:00!05:30!06:00!06:30!07:00!07:30!08:00!08:30" &
        # @TODO This should call conf-schedule.sh with timestamps

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
