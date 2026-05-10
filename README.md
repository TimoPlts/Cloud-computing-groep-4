# Smart Sensor Gateway met monitoring en automatisatie

Containergebaseerde edge gateway voor het verzamelen, verwerken, opslaan en visualiseren van industriele sensordata. De stack ontvangt gesimuleerde controllerdata via MQTT, valideert die in Node-RED, schrijft correcte metingen naar InfluxDB en toont de data in Grafana. Portainer wordt gebruikt voor containerbeheer.

## Architectuur

De volledige omgeving draait via Docker Compose op een eigen bridge-netwerk `cloudnet`.

```text
sensor-sim
  | MQTT publish
  v
Mosquitto broker
  | MQTT subscribe
  v
Node-RED
  | validatie + transformatie
  v
InfluxDB
  | Flux queries
  v
Grafana dashboard

Portainer beheert de containers.
discord-monitor controleert de services en kan alerts naar Discord sturen.
```

## Services

| Service | Functie | URL/poort |
| --- | --- | --- |
| Mosquitto | Lokale MQTT-broker | `localhost:1883` |
| sensor-sim | Python simulator die sensordata publiceert | intern |
| Node-RED | MQTT consumer, validatie en opslaglogica | `http://localhost:1880` |
| InfluxDB | Tijdreeksdatabase voor meetgegevens | `http://localhost:8086` |
| Grafana | Dashboard voor live en gemiddelde waarden | `http://localhost:3000` |
| Portainer | Beheer en status van containers | `http://localhost:9000` |
| discord-monitor | Eenvoudige servicebewaking met Discord alerts | intern |

## Info voor leerkracht

De stack staat gedeployed op de VM:

```text
10.20.1.37
```

Belangrijke URLs:

| Component | URL |
| --- | --- |
| Node-RED | `http://10.20.1.37:1880` |
| InfluxDB | `http://10.20.1.37:8086` |
| Grafana | `http://10.20.1.37:3000` |
| Portainer | `http://10.20.1.37:9000` |

Discord server invite voor de monitorbot:

```text
https://discord.gg/ADnVwJ7mJK
```

## Dataflow

De simulator publiceert elke seconde data naar Mosquitto.

MQTT topics:

| Topic | Payload | Betekenis |
| --- | --- | --- |
| `controller/joystick` | `{"x": 512, "y": 700}` | Joystickpositie |
| `controller/button` | `{"a": 1, "b": 0}` | Knopstatussen |

De button simulator stuurt bewust soms waarde `2`. Dat is een foutieve meting, want buttons mogen alleen `0` of `1` zijn. Node-RED dropt die waarden en logt bijvoorbeeld:

```text
Ongeldige button data gedropt: a=2, b=1
```

Dit bewijst dat de validatielaag werkt en dat enkel correcte data naar InfluxDB gaat.

## Node-RED verwerking

Node-RED leest beide MQTT topics in en gebruikt function nodes voor de datalogica.

Joystickvalidatie:

- `x` en `y` moeten tussen `0` en `1023` liggen
- ongeldige waarden worden niet doorgestuurd
- voor geldige waarden wordt `magnitude` berekend
- data wordt opgeslagen als measurement `joystick`

Buttonvalidatie:

- `a` en `b` moeten `0` of `1` zijn
- foutieve waarden worden gelogd en gedropt
- geldige waarden worden opgeslagen als measurement `button`

InfluxDB bucket:

```text
sensordata
```

InfluxDB organization:

```text
groep4
```

## Grafana dashboard

Het dashboard `Smart Sensor Gateway` wordt automatisch geprovisioned vanuit:

```text
grafana/dashboards/smart-sensor-gateway.json
```

Het dashboard bevat:

- live joystick X
- live joystick Y
- live button A
- live button B
- gemiddelde joystickwaarden per uur
- gemiddelde buttonwaarden per uur
- gemiddelde joystickwaarden per 24 uur
- gemiddelde buttonwaarden per 24 uur

Grafana gebruikt Flux queries op de InfluxDB bucket `sensordata`.

## Installatie

Vereisten:

- Docker
- Docker Compose
- Git

Clone de repo en start de stack:

```bash
git clone <repo-url>
cd Cloud-computing-groep-4
docker compose up -d --build
```

Controleer de containers:

```bash
docker compose ps
```

Bekijk logs:

```bash
docker compose logs -f
```

Stop de stack:

```bash
docker compose down
```

## Inloggegevens

De configuratie wordt via `.env` ingesteld zodat de evaluatie-omgeving meteen kan starten.

| Component | Gebruiker | Wachtwoord/token |
| --- | --- | --- |
| Grafana | `admin` | zie `GRAFANA_ADMIN_PASSWORD` in `.env` |
| InfluxDB | `admin` | zie `INFLUXDB_ADMIN_PASSWORD` in `.env` |
| Portainer | `admin` | zie `PORTAINER_ADMIN_PASSWORD` in `.env` |

Voor een productieomgeving zouden deze secrets niet in de repository staan, maar via een server-side `.env` beheerd worden.

## Portainer

Portainer is beschikbaar op:

```text
http://localhost:9000
```

Portainer toont de status van alle containers, images, volumes en netwerken. De compose-config geeft bij eerste start automatisch een admin password hash mee. Als er al een oud `portainer_data` volume bestaat, blijft de bestaande Portainer-config actief.

## Monitoring

De stack bevat een `discord-monitor` container. Die controleert periodiek:

- InfluxDB health endpoint
- Grafana health endpoint
- Portainer status endpoint
- Node-RED webinterface
- Mosquitto TCP-poort
- sensor-sim containerstatus

Wanneer een service van status verandert, stuurt de monitor een Discord bericht. Zet hiervoor een webhook in `.env`:

```bash
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
```

Zonder webhook is de monitor niet nuttig. Voor lokale demo kan je de rest van de stack blijven gebruiken zonder Discord alerts.

## CI/CD en automatisatie

### Simpele deploy

Het minimale deployscript voor de opdracht staat in:

```text
scripts/deploy.sh
```

Gebruik:

```bash
chmod +x ./scripts/deploy.sh
./scripts/deploy.sh
```

Dit script:

1. bouwt de containers opnieuw
2. stopt de oude stack
3. start de nieuwe stack detached

### Automatische deploy via polling

Voor de automatische VM-deploy zet je de repo in `/opt/cloud-computing-groep-4` en activeer je de systemd timer:

```bash
sudo mkdir -p /opt/cloud-computing-groep-4
sudo chown "$USER":"$USER" /opt/cloud-computing-groep-4
git clone <repo-url> /opt/cloud-computing-groep-4
cd /opt/cloud-computing-groep-4
chmod +x ./scripts/auto-deploy-poll.sh
chmod +x ./scripts/deploy-with-rollback.sh
sudo cp ./scripts/systemd/cloud-groep-4-auto-deploy.service /etc/systemd/system/
sudo cp ./scripts/systemd/cloud-groep-4-auto-deploy.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now cloud-groep-4-auto-deploy.timer
```

De timer start `scripts/auto-deploy-poll.sh`. Die checkt `origin/main` en voert bij een nieuwe commit automatisch `scripts/deploy-with-rollback.sh` uit. De rollback gebeurt dus automatisch en moet normaal niet apart gestart worden.

Controle:

```bash
systemctl status cloud-groep-4-auto-deploy.timer --no-pager
journalctl -u cloud-groep-4-auto-deploy.service -n 50 --no-pager
```

Voor een eenmalige test kan je het rollback-script wel handmatig starten:

```bash
./scripts/deploy-with-rollback.sh
```

## Backup

Als bonus bevat het project een backupscript voor Docker volumes:

```text
scripts/backup-volumes.sh
```

Het script maakt `.tar.gz` backups van:

- InfluxDB data
- Node-RED data
- Portainer data

Gebruik:

```bash
chmod +x ./scripts/backup-volumes.sh
./scripts/backup-volumes.sh
```

Andere outputmap:

```bash
./scripts/backup-volumes.sh --output-dir backups-demo
```
