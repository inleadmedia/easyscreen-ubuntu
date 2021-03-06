#!/bin/bash

#xrandr --output HDMI-1 --auto --primary
# @TODO Somehow this has to be uncomment device is external.
#xrandr --output eDP1 --off

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

CLIENTURL=$(cat /home/kiosk/screen-url.txt)

# Check connection and run Chrome
sleep 2s

fnCheckConnection() {
	notify-send 'Screen Setup' 'Verifying the internet connection.' -u low
	sleep 4s
	WGET="/usr/bin/wget"
	$WGET -q --tries=10 --timeout=5 http://www.google.com -O /tmp/index.google &> /dev/null

	if [ ! -s /tmp/index.google ];then
		notify-send 'easyScreen' 'Cannot connect to the internet. Re-attempting...' -u low
		sleep 4s
		fnCheckConnection `expr $1 + 1`
	else
		notify-send 'easyScreen' 'Connected to the internet. Opening the screen.' -u low
		sleep 4s

		notify-send 'easyScreen' 'Please wait - we are almost done.' -u low

		# @TODO Should be uncommented by conf.sh
		# Uncoment this line if you need Linux app to start
		# sudo node /home/kiosk/es-linux-app/./index.js &
		
		# Getting default welcome screen

		# Restart TW
		sudo teamviewer daemon restart
		sleep 2s

		# Run Chrome and open tab
		pkill -f -- "chrome"
		sleep 2s
		/usr/bin/google-chrome --disable-pinch --overscroll-history-navigation=0 --no-first-run \
					--disable-translate --no-default-browser-check --password-store=basic \
					--enable-native-gpu-memory-buffers --enable-features="CheckerImaging" \
					--incognito --window-size=1920,1080 --kiosk --window-position=0,0 \
          --check-for-update-interval=604800 \
					$CLIENTURL &

	fi
}

fnCheckConnection "1"
