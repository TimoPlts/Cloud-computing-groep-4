param(
    [string]$OutputDir = "backups"
)

$ErrorActionPreference = "Stop"

function Get-ComposeProjectName {
    $configJson = docker compose config --format json
    if (-not $configJson) {
        throw "Kon docker compose config niet uitlezen."
    }

    $config = $configJson | ConvertFrom-Json
    if (-not $config.name) {
        throw "Compose projectnaam niet gevonden in config."
    }

    return [string]$config.name
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $repoRoot

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupRoot = Join-Path $repoRoot $OutputDir
if (-not (Test-Path $backupRoot)) {
    New-Item -ItemType Directory -Path $backupRoot | Out-Null
}

$projectName = Get-ComposeProjectName
$logicalVolumes = @("influxdb-data", "nodered-data", "portainer_data")

$composeVolumes = docker volume ls --filter "label=com.docker.compose.project=$projectName" --format "{{.Name}}"
if (-not $composeVolumes) {
    throw "Geen compose volumes gevonden voor project '$projectName'."
}

Write-Host "Compose project: $projectName"
Write-Host "Backup map: $backupRoot"

foreach ($logicalVolume in $logicalVolumes) {
    $dockerVolume = $composeVolumes | Where-Object {
        $_ -eq "$projectName`_$logicalVolume" -or $_ -eq "$projectName-$logicalVolume"
    } | Select-Object -First 1

    if (-not $dockerVolume) {
        Write-Warning "Volume niet gevonden, wordt overgeslagen: $logicalVolume"
        continue
    }

    $archiveName = "$dockerVolume-$timestamp.tar.gz"
    $archivePath = Join-Path $backupRoot $archiveName

    Write-Host "Backup bezig: $dockerVolume"

    $tempContainer = docker create -v "${dockerVolume}:/volume:ro" alpine sh -c "tar -czf /tmp/backup.tar.gz -C /volume ."
    if (-not $tempContainer) {
        throw "Kon tijdelijke container niet maken voor volume $dockerVolume"
    }

    try {
        docker start -a $tempContainer | Out-Null
        docker cp "${tempContainer}:/tmp/backup.tar.gz" $archivePath | Out-Null
        Write-Host "Backup klaar: $archivePath"
    }
    finally {
        docker rm -f $tempContainer | Out-Null
    }
}

Write-Host "Alle beschikbare volume-backups zijn voltooid."
