#!/bin/bash
shutdown=$(cat /home/kiosk/schedule-shutdown.txt)
startup=$(cat /home/kiosk/schedule-startup.txt)

echo "$TIMESTAMP # Scheduled Suspend and Resume"
sudo touch /etc/systemd/system/auto-suspend.timer
cat <<EOF>> /etc/systemd/system/auto-suspend.timer
[Unit]
Description=Automatically suspend on a schedule
[Timer]
OnCalendar=*-*-* $shutdown
[Install]
WantedBy=timers.target
EOF

sudo touch /etc/systemd/system/auto-suspend.service
cat <<EOF>> /etc/systemd/system/auto-suspend.service
[Unit]
Description=Suspend
[Service]
Type=oneshot
ExecStart=/bin/systemctl suspend
EOF

sudo touch /etc/systemd/system/auto-resume.timer
cat <<EOF>> /etc/systemd/system/auto-resume.timer
[Unit]
Description=Automatically resume on a schedule

[Timer]
OnCalendar=*-*-* $startup
WakeSystem=true
[Install]
WantedBy=timers.target
EOF

sudo touch /etc/systemd/system/auto-resume.service
cat <<EOF>> /etc/systemd/system/auto-resume.service

[Unit]
Description=Does nothing
[Service]
Type=oneshot
ExecStartPre=/bin/bash -c '/bin/true && /bin/sleep 60'
ExecStart=/bin/bash -c '/bin/systemctl reboot'
EOF

sudo systemctl enable auto-suspend.timer
sudo systemctl start auto-suspend.timer

sudo systemctl enable auto-resume.timer
sudo systemctl start auto-resume.timer
