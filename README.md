# Cloud-computing-groep-4

## Bonus: Volume backup script

Dit project bevat een backupscript voor de Docker volumes van:

- InfluxDB (`influxdb-data`)
- Node-RED (`nodered-data`)
- Portainer (`portainer_data`)

### Handige searches voor info
- powershell docker volume backup script
- powershell tar gz create
- powershell docker compose automation
- powershell script parameters example

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