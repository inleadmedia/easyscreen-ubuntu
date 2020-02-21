#!/bin/bash

# Run this script in display 0 - the monitor
#export DISPLAY=:0

# Hide the mouse from the display
unclutter &

# If Chromium crashes (usually due to rebooting), clear the crash flag so we don't have the annoying warning bar
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/kiosk/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /home/kiosk/.config/chromium/Default/Preferences

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

		# Restart TW
		sudo teamviewer daemon restart
		sleep 3s

		# Uncoment this line if you need Linux app to start
#		sudo node /home/linux/es-linux-app/index.js &
		# Getting default welcome screen

#		git clone -b release https://869173763bec469dd2f846e660801c1c4068ecb3@github.com/inleadmedia/es-license-service.git;
#		cp -rf /home/linux/es-license-service/start_page/index.html /home/linux/index.html;
#		sleep 1
		# Get TW ID
#		TWID="$(grep -oP '(?<=ClientIDOfTSUser = )[0-9]+' .config/teamviewer/client.conf)";
#		reg="s/teamViewerId\" value=\"/&$TWID/";
#		sed "$reg" index.html > start.html

		# Run Chromium and open tabs
		pkill -f -- "chromium-browser"
		sleep 2s
		/usr/bin/chromium-browser --no-default-browser-check --password-store=basic --enable-native-gpu-memory-buffers --enable-features="CheckerImaging" --incognito --window-size=1920,1080 --kiosk --window-position=0,0 https://admin-vinbib.easyscreen.io/web/ &

	fi
}

fnCheckConnection "1"
