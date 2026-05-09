# Backup Script

## Purpose

The backup script is a bonus feature that creates compressed backups of the main Docker volumes used by the project. This is important because the most valuable project data is not stored inside the container filesystem itself, but inside persistent Docker volumes.

## Implementation

The script is located at [scripts/backup-volumes.sh](../scripts/backup-volumes.sh).

Its goal is to back up the following logical volumes:

- `influxdb-data`
- `nodered-data`
- `portainer_data`

These volumes contain:

- InfluxDB measurements and metadata
- Node-RED flow data and settings
- Portainer configuration data

## How the Script Works

The script first determines the active Docker Compose project name. This is necessary because Docker prefixes volume names with the compose project name.

After that, it:

1. searches for the real Docker volume names
2. creates a temporary Alpine container for each volume
3. mounts the target volume read-only inside that container
4. creates a `.tar.gz` archive from the mounted data
5. copies the archive back to the host
6. removes the temporary container

This approach is useful because it works directly with Docker volumes without needing to know their internal host path.

## Output

By default, the archives are stored in the `backups` directory in the repository root. Each file name includes a timestamp so older backups are not overwritten.

Example naming pattern:

```text
<docker-volume-name>-YYYYMMDD-HHMMSS.tar.gz
```

## Usage

Default output directory:

```bash
./scripts/backup-volumes.sh
```

Custom output directory:

```bash
./scripts/backup-volumes.sh --output-dir backups-demo
```

## Why This Is Useful

The script improves the project in two ways:

- it protects persistent project data
- it demonstrates operational thinking beyond the minimum assignment requirements

It is especially relevant for services such as InfluxDB and Node-RED, because rebuilding the containers alone would not restore the stored data.

## Limitations

The script creates backups, but it does not include a restore script yet. A future improvement would be to add a documented restore procedure so the full backup lifecycle is covered.
