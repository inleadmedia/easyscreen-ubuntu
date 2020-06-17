#!/bin/bash

#xrandr --output HDMI-1 --auto --primary
xrandr --output eDP1 --off

# Run this script in display 0 - the monitor
#export DISPLAY=:0

# Disable gestures and OSK
gnome-shell-extension-tool -e disable-gestures@mattbell.com.au
gnome-shell-extension-tool -e On_Screen_Keyboard_Button@bradan.eu
gnome-shell-extension-tool -e cariboublocker@git.keringar.xyz

# Hide the mouse from the display
unclutter &

# If Chrome crashes (usually due to rebooting), clear the crash flag so we don't have the annoying warning bar
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/kiosk/.config/google-chrome/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /home/kiosk/.config/google-chrome/Default/Preferences

# @TODO Should be set by conf.sh
CLIENTURL="https://admin-esbbib.easyscreen.io/web/"

# Check connection and run Chrome
sleep 3s
fnCheckConnection() {
	notify-send 'Screen Setup' 'Verifying the internet connection.' -t 3000
	sleep 2s
	WGET="/usr/bin/wget"
	$WGET -q --tries=10 --timeout=5 http://www.google.com -O /tmp/index.google &> /dev/null

	if [ ! -s /tmp/index.google ];then
		notify-send 'Screen Setup' 'Cannot connect to the internet. Re-attempting...' -t 3000
		sleep 4s
		fnCheckConnection `expr $1 + 1`
	else
		notify-send 'Screen setup' 'Connected to the internet. Opening the screen' -t 3000
		sleep 1s

		notify-send 'Screen Setup' 'Please wait - We are almost done' -t 6000

		# @TODO Should be uncommented by conf.sh
		# Uncoment this line if you need Linux app to start
		# sudo node /home/kiosk/es-linux-app/./index.js &
		
		# Getting default welcome screen

#		git clone -b release https://c84c0799e0d67cb7feabc699b0b5812607e8935a@github.com/inleadmedia/es-license-service.git;
#		cp -rf /home/kiosk/es-license-service/start_page/index.html /home/kiosk/index.html;
#		sleep 1
		# Restart TW
		sudo teamviewer daemon restart
		sleep 3s
#		# Get TW ID
#		TWID="$(grep -oP '(?<=ClientIDOfTSUser = )[0-9]+' .config/teamviewer/client.conf)";
#		reg="s/teamViewerId\" value=\"/&$TWID/";
#		sed "$reg" index.html > start.html

		# Run Chrome and open tab
		pkill -f -- "chrome"
		sleep 2s
		/usr/bin/google-chrome --disable-pinch --overscroll-history-navigation=0 --no-first-run \
		                       --disable-translate --no-default-browser-check --password-store=basic \
				       --enable-native-gpu-memory-buffers --enable-features="CheckerImaging" \
				       --incognito --window-size=1920,1080 --kiosk --window-position=0,0 \
				       $CLIENTURL &

	fi
}

fnCheckConnection "1"
