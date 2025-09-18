#!/usr/bin/env bash

sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y libc6-i386 lib32gcc-s1 lib32stdc++6 wget tar ca-certificates

touch /home/arma/server/server.json
touch /etc/systemd/system/arma-reforger.service


# create a clean user + folders (suggested)
sudo useradd -m -r -s /bin/bash arma
sudo -u arma bash -lc '
mkdir -p ~/steamcmd ~/server
cd ~/steamcmd
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzf steamcmd_linux.tar.gz
./steamcmd.sh +login anonymous +force_install_dir "$HOME/server" +app_update 1874900 validate +quit
'

# create-arma-reforger-service.sh
#
# Requires:  root privileges (or sudo)
# Purpose:   Write /etc/systemd/system/arma-reforger.service
#            and reload systemd so the unit can be enabled/started.

#set -euo pipefail

SERVICE_FILE="/etc/systemd/system/arma-reforger.service"

# 1️⃣  Write the unit file
cat <<'EOF' | sudo tee "$SERVICE_FILE" >/dev/null
[Unit]
Description=Arma Reforger Dedicated Server
After=network-online.target
Wants=network-online.target

[Service]
User=arma
WorkingDirectory=/home/arma/server
ExecStart=/home/arma/server/ArmaReforgerServer -config /home/arma/server/server.json -profile /home/arma/profile -loadSessionSave
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# 2️⃣  Make sure the file has the right owner/group/permissions
sudo chmod 644 "$SERVICE_FILE"

# 3️⃣  Reload systemd to recognise the new unit
sudo systemctl daemon-reload

# 4️⃣  (Optional) Enable the service now so it starts on boot
# Uncomment the next line if you want that behaviour.
# sudo systemctl enable arma-reforger.service

echo "✔︎ /etc/systemd/system/arma-reforger.service created and systemd reloaded."
