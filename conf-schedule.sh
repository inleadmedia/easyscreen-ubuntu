#!/bin/bash

echo "$TIMESTAMP # Scheduled Suspend and Resume"
sudo -u kiosk tee /etc/systemd/system/auto-suspend.timer >/dev/null <<'EOF'
[Unit]
Description=Automatically suspend on a schedule
[Timer]
OnCalendar=*-*-* 23:30:00
[Install]
WantedBy=timers.target
EOF

sudo -u kiosk tee /etc/systemd/system/auto-suspend.service >/dev/null <<'EOF'
[Unit]
Description=Suspend
[Service]
Type=oneshot
ExecStart=/bin/systemctl suspend
EOF

sudo -u kiosk tee /etc/systemd/system/auto-resume.timer >/dev/null <<'EOF'
[Unit]
Description=Automatically resume on a schedule

[Timer]
OnCalendar=*-*-* 06:30:00
WakeSystem=true
[Install]
WantedBy=timers.target
EOF

sudo -u kiosk tee /etc/systemd/system/auto-resume.service >/dev/null <<'EOF'
[Unit]
Description=Does nothing
[Service]
Type=oneshot
ExecStartPre=/bin/bash -c '/bin/true && /bin/sleep 60'
ExecStart=/bin/bash -c '/bin/systemctl reboot'
EOF

sudo -u kiosk systemctl enable auto-suspend.timer
sudo -u kiosk systemctl start auto-suspend.timer

sudo -u kiosk systemctl enable auto-resume.timer
sudo -u kiosk systemctl start auto-resume.timer
