sudo -u arma bash -lc '
cd ~/steamcmd
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzf steamcmd_linux.tar.gz
./steamcmd.sh +login anonymous +force_install_dir "$HOME/server" +app_update 1874900 validate +quit
'
