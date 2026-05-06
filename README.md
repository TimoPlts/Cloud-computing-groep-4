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

Voor je de stack start, maak eerst een lokale `.env` op basis van `.env.example` en vul je eigen secrets in.

Heruitrollen via het deployscript:

```bash
./scripts/deploy.sh
```

## Automatische deploy op de VM

Voor automatische uitrol zonder GitHub SSH-toegang bevat deze repo nu een lokale VM-opzet:

- `./scripts/deploy-with-rollback.sh`: voert een deploy uit en rolt terug als health checks falen
- `./scripts/auto-deploy-poll.sh`: checkt of `origin/main` een nieuwe commit heeft en start dan de deploy
- `./scripts/systemd/cloud-groep-4-auto-deploy.service`
- `./scripts/systemd/cloud-groep-4-auto-deploy.timer`

De flow op de VM is:

1. de timer draait elke minuut
2. de poller doet `git fetch origin`
3. bij een nieuwe commit start het rollback-deployscript
4. dat script bouwt de stack opnieuw en controleert containers en HTTP endpoints
5. bij een mislukte deploy schakelt het terug naar de vorige commit

### Eenmalige VM-setup

Clone de repo op de VM en maak de scripts uitvoerbaar:

```bash
cd /opt/cloud-computing-groep-4
chmod +x ./scripts/deploy-with-rollback.sh
chmod +x ./scripts/auto-deploy-poll.sh
```

Installeer daarna de `systemd` units:

```bash
sudo cp ./scripts/systemd/cloud-groep-4-auto-deploy.service /etc/systemd/system/
sudo cp ./scripts/systemd/cloud-groep-4-auto-deploy.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now cloud-groep-4-auto-deploy.timer
```

Controle:

```bash
systemctl status cloud-groep-4-auto-deploy.timer --no-pager
journalctl -u cloud-groep-4-auto-deploy.service -n 50 --no-pager
```

### Pad aanpassen indien nodig

De voorbeeld-`systemd` files gebruiken `/opt/cloud-computing-groep-4` als projectmap. Pas dat aan als jullie repo op de VM ergens anders staat, bijvoorbeeld `/root/Cloud-computing-groep-4`.

### Belangrijke nuance

De rollback dekt een mislukte of ongezonde deploy. Bij een echte security-compromise moet je daarnaast ook secrets roteren en de VM zelf onderzoeken.

## Secrets configureren

Echte wachtwoorden en tokens horen niet in Git. Gebruik daarom een lokale `.env`:

```bash
cp .env.example .env
```

Vul daarna minstens deze variabelen in:

- `INFLUXDB_ADMIN_PASSWORD`
- `INFLUXDB_ADMIN_TOKEN`
- `GRAFANA_ADMIN_PASSWORD`
- `NODE_RED_CREDENTIAL_SECRET`

De `.env` blijft lokaal en wordt niet gecommit.

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
