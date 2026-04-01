# Cloud-computing-groep-4

## andere info......

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