# armaConfigs

Arma Reforger Dedicated Server Configurations

## Structure

- **server-*.json**  
  Server configuration files for different scenarios and maps.  
  Example:  
  - `server-Everon.json`  
  - `server-Ruha.json`  
  - `server-RamadiConflict.json`  
  - `server-Ruha_Conflict.json`  
  - `server-Ruha-NightTime.json`  
  - `server-RuhaPvE.json`  
  - `server-Everon-gm.json`

- **Scripts/**  
  Utility scripts for installing, patching, and running the server.
  - `server-install.sh` – Installs dependencies, creates user, sets up systemd service.
  - `arma-srv-patch.sh` – Updates Arma Reforger server using SteamCMD.
  - `run-server.sh` – Runs the server with a specified config.

## Usage

### Install Server

Run the install script to set up the server and systemd service:

```sh
sudo bash [server-install.sh](http://_vscodecontentref_/0)
```
