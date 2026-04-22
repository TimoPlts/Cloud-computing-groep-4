# Cloud-computing-groep-4

## Basisstack

De basis draait volledig via Docker Compose:

- Mosquitto: MQTT-broker op `localhost:1883`
- Sensor simulator: publiceert joystick- en buttondata naar Mosquitto
- Node-RED: leest MQTT-data, valideert ze en schrijft correcte metingen naar InfluxDB
- InfluxDB: tijdreeksdatabase voor de meetwaarden
- Grafana: dashboard op `http://localhost:3000`
- Portainer: containerbeheer op `http://localhost:9000`

Binnen het Docker-netwerk gebruiken containers de servicenaam `mosquitto` als MQTT-host. Vanaf de hostmachine kan je de broker bereiken via `localhost:1883`.

Start de stack:

```bash
docker compose up -d --build
```

Heruitrollen via het deployscript:

```bash
./scripts/deploy.sh
```

## Bonus: Volume backup script

Dit project bevat een backupscript voor de Docker volumes van:

- InfluxDB (`influxdb-data`)
- Node-RED (`nodered-data`)
- Portainer (`portainer_data`)

### Handige searches voor info
#### windows
- powershell docker volume backup script
- powershell tar gz create
- powershell docker compose automation
- powershell script parameters example

#### linux
- docker volume backup tar alpine
- docker compose volume backup script
- restore docker volume from tar.gz
- posix shell argument parsing

### Backup uitvoeren

Voer dit uit in de root folder:

```powershell
./scripts/backup-volumes.ps1
```

Wat als je een andere opslag map wil?:

```powershell
./scripts/backup-volumes.ps1 -OutputDir backups-demo
```

De backups worden opgeslagen als `.tar.gz` met timestamp in de gekozen map.

### Backup uitvoeren op de VM

Maak het script uitvoerbaar:

```bash
chmod +x ./scripts/backup-volumes.sh
```

Doe dit in de root folder:

```bash
./scripts/backup-volumes.sh
```

Wat als je hier ook een andere opslag map wil?:

```bash
./scripts/backup-volumes.sh --output-dir backups-demo
```
