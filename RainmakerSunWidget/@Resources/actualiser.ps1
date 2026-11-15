# Données NOAA et image NASA SDO ; Windows PowerShell 5.1, aucune clé requise.
param([string]$FixtureDirectory = '')
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$now = [DateTimeOffset]::UtcNow
$vars = [ordered]@{
    Rayons='--'; RayonsHeure='--'; RayonsEtat='Indisponible';
    Vent='--'; VentHeure='--'; VentEtat='Indisponible';
    Bz='--'; BzHeure='--'; BzEtat='Indisponible';
    Flux='--'; FluxHeure='--'; FluxEtat='Indisponible';
    Eruption='--'; EruptionHeure='--'; ImageHeure='--'; ImageEtat='indisponible';
    Etat='Indisponible'; MAJ=(Get-Date -Format 'HH:mm'); PremierDemarrage='0'
}
function Get-Feed([string]$name, [string]$url) {
    if ($FixtureDirectory) { return (Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $FixtureDirectory ($name + '.json')) | ConvertFrom-Json) }
    return Invoke-RestMethod -Uri $url -TimeoutSec 12 -UseBasicParsing -Headers @{ 'User-Agent' = 'RainmeterSunWidget/1.0' }
}
function Utc-Date($value) {
    if (-not $value) { throw 'Date absente' }
    $s = [string]$value
    if ($s -notmatch '(Z|[+-]\d{2}:\d{2})$') { $s += 'Z' }
    return [DateTimeOffset]::Parse($s).ToUniversalTime()
}
function Safe($value) {
    if ($null -eq $value) { return '--' }
    $s = ([string]$value) -replace '[\r\n\t#\[\]"%]', ' ' -replace '\s+', ' '
    if (-not $s.Trim()) { return '--' }
    return $s.Trim()
}
function Load-Value([string]$name, [string]$url, [string]$property, [string]$prefix, [int]$ageMinutes, [string]$format) {
    try {
        $item = @(Get-Feed $name $url)[0]
        $dt = Utc-Date $item.time_tag
        $vars[$prefix + 'Heure'] = $dt.ToString('dd/MM HH:mm')
        $age = ($now - $dt).TotalMinutes
        if ($age -gt $ageMinutes -or $age -lt -15) { $vars[$prefix + 'Etat'] = 'Mesure ancienne ou date invalide'; return $false }
        $val = $item.$property
        if ($null -eq $val -or [string]$val -eq '') { throw 'Valeur absente' }
        if ($format -eq 'class') {
            if ([string]$val -notmatch '^[ABCMX]\d+(\.\d+)?$') { throw 'Classe inconnue' }
            $vars[$prefix] = [string]$val
        } else {
            $number = [double]::Parse([string]$val, [Globalization.CultureInfo]::InvariantCulture)
            if ([double]::IsNaN($number) -or [double]::IsInfinity($number)) { throw 'Nombre invalide' }
            $vars[$prefix] = $number.ToString($format, [Globalization.CultureInfo]::InvariantCulture)
        }
        $vars[$prefix + 'Etat'] = 'À jour'
        return $true
    } catch { $vars[$prefix + 'Etat'] = 'Indisponible'; return $false }
}
$mutex = New-Object System.Threading.Mutex($false, 'Local\RainmeterSunWidget')
$locked = $false
try {
    try { $locked = $mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $locked = $true }
    if (-not $locked) {
        # L'autre panneau actualise déjà : attendre sa fin, puis recharger son résultat.
        try { $locked = $mutex.WaitOne(90000) } catch [Threading.AbandonedMutexException] { $locked = $true }
        exit 0
    }
    $okX = Load-Value 'xray' 'https://services.swpc.noaa.gov/json/goes/primary/xray-flares-latest.json' 'current_class' 'Rayons' 60 'class'
    $okVent = Load-Value 'vent' 'https://services.swpc.noaa.gov/products/summary/solar-wind-speed.json' 'proton_speed' 'Vent' 90 'F0'
    $okBz = Load-Value 'bz' 'https://services.swpc.noaa.gov/products/summary/solar-wind-mag-field.json' 'bz_gsm' 'Bz' 90 'F1'
    $okFlux = Load-Value 'flux' 'https://services.swpc.noaa.gov/products/summary/10cm-flux.json' 'flux' 'Flux' 4320 'F0'
    try {
        $event = @(Get-Feed 'xray' 'https://services.swpc.noaa.gov/json/goes/primary/xray-flares-latest.json')[0]
        $eventDate = Utc-Date $event.max_time
        if ([string]$event.max_class -notmatch '^[ABCMX]\d+(\.\d+)?$') { throw 'Classe absente' }
        if ($eventDate -gt $now.AddMinutes(15)) { throw 'Date future' }
        $vars.Eruption = [string]$event.max_class
        $vars.EruptionHeure = $eventDate.ToString('dd/MM HH:mm')
    } catch { }
    $imagePath = Join-Path $dir 'Images\soleil.jpg'
    if (-not $FixtureDirectory) {
        if (-not (Test-Path -LiteralPath (Join-Path $dir 'Images'))) { New-Item -ItemType Directory -Path (Join-Path $dir 'Images') -Force | Out-Null }
        $tmpImage = Join-Path $dir ('Images\soleil-' + [guid]::NewGuid().ToString('N') + '.tmp')
        try {
            Invoke-WebRequest -Uri 'https://sdo.gsfc.nasa.gov/assets/img/latest/latest_512_0304.jpg' -OutFile $tmpImage -TimeoutSec 15 -UseBasicParsing
            Add-Type -AssemblyName System.Drawing
            $img = [Drawing.Image]::FromFile($tmpImage)
            try { if ($img.Width -lt 100 -or $img.Height -lt 100) { throw 'Image invalide' } } finally { $img.Dispose() }
            Move-Item -LiteralPath $tmpImage -Destination $imagePath -Force
        } catch { if (Test-Path -LiteralPath $tmpImage) { Remove-Item -LiteralPath $tmpImage -Force } }
    }
    if (Test-Path -LiteralPath $imagePath) {
        $stamp = (Get-Item -LiteralPath $imagePath).LastWriteTimeUtc
        $vars.ImageHeure = $stamp.ToString('dd/MM HH:mm')
        if (($now.UtcDateTime - $stamp).TotalHours -le 6) { $vars.ImageEtat = 'image UV' } else { $vars.ImageEtat = 'image ancienne' }
    }
    if ($okX -and $okVent -and $okBz -and $okFlux -and $vars.ImageEtat -eq 'image UV') { $vars.Etat = 'À jour' }
    elseif ($okX -or $okVent -or $okBz -or $okFlux -or $vars.ImageEtat -ne 'indisponible') { $vars.Etat = 'Partiel / ancien' }
    $content = "[Variables]`r`n" + (($vars.GetEnumerator() | ForEach-Object { $_.Key + '=' + (Safe $_.Value) }) -join "`r`n") + "`r`n"
    $inc = Join-Path $dir 'donnees.inc'
    $temp = Join-Path $dir ('donnees-' + [guid]::NewGuid().ToString('N') + '.tmp')
    [IO.File]::WriteAllText($temp, $content, [Text.Encoding]::Unicode)
    Move-Item -LiteralPath $temp -Destination $inc -Force
} finally {
    if ($locked) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}
