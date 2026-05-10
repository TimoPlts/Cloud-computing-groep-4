# Backup script

## Purpose

The backup script is a bonus feature that creates compressed backups of the main Docker volumes used by the project. Persistent data (InfluxDB measurements, Node-RED flows, Portainer configuration) lives in Docker volumes and must be backed up separately from container images.

## Location

The Linux script is located at `scripts/backup-volumes.sh`. Run it from the repository root.

## What is backed up

- `influxdb-data`
- `nodered-data`
- `portainer_data`

These contain respectively InfluxDB data, Node-RED flows/settings, and Portainer configuration.

## How it works (brief)

1. Determine the Docker Compose project name (used as volume prefix).
2. List compose-managed volumes and find the ones matching the logical names above.
3. For each volume: create a temporary Alpine container, mount the volume read-only and create a `.tar.gz` of its contents.
4. Copy the archive from the temporary container to the host and remove the container.

This method works without knowledge of the host paths of Docker volumes.

## Output and filenames

Archives are stored under the `backups/` folder by default. Filenames include the compose volume name and a timestamp, e.g.:

```
cloud-computing-groep-4_nodered-data-20260506-153000.tar.gz
```

## Usage

Run the script (Linux VM):

```bash
chmod +x ./scripts/backup-volumes.sh
./scripts/backup-volumes.sh
```

Custom output directory:

```bash
./scripts/backup-volumes.sh --output-dir backups-demo
```

## Restore (examples)

Always create a fresh backup before restoring the current state. Stop services that use the target volume to avoid consistency issues.

Example restore using a one-liner (mount backup folder):

```bash
# set variables
VOLUME="cloud-computing-groep-4_nodered-data"
BACKUP="backups/cloud-computing-groep-4_nodered-data-20260506-153000.tar.gz"

docker run --rm -v "$VOLUME:/volume" -v "$(pwd)/backups:/backups" alpine sh -c "tar -xzf /backups/$(basename $BACKUP) -C /volume"
```

Alternative (copy to temp container and extract):

```bash
tmp=$(docker create -v "$VOLUME:/volume" alpine true)
docker cp "$BACKUP" "$tmp:/tmp/backup.tar.gz"
docker start -a "$tmp" >/dev/null
docker exec "$tmp" sh -c "tar -xzf /tmp/backup.tar.gz -C /volume"
docker rm -f "$tmp"
```

After restore, start the stack:

```bash
docker compose up -d
```

Notes:
- Stop services before restore to avoid race conditions.
- Verify file ownership and permissions after extraction; adjust with `chown`/`chmod` if necessary.

## Scheduling (optional)

If you want automated backups, use `cron` or a systemd timer. Example cron entries (daily at 03:00, cleanup older than 14 days):

```cron
0 3 * * * /opt/cloud-computing-groep-4/scripts/backup-volumes.sh --output-dir /var/backups/cloud-groep-4
0 4 * * * find /var/backups/cloud-groep-4 -type f -name '*.tar.gz' -mtime +14 -delete
```

## Limitations

- This is a snapshot backup; it is not real-time replication.
- Backups consume host disk space; ensure sufficient capacity.
- The script is read-only and does not modify volumes.
- For high-write workloads (InfluxDB) there can be consistency issues when backing up while writes occur; consider briefly stopping services if strict consistency is required.

## Improvements

- Add a dedicated `restore` script that performs stop/restore/start automatically and validates the result.
- Add retention and optional upload to offsite storage (S3/MinIO) for resilience.

## References

- Docker volumes: https://docs.docker.com/storage/volumes/
- tar manual: https://www.gnu.org/software/tar/manual/tar.html
