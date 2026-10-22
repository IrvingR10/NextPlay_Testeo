param(
    [string]$DeviceId
)

$ErrorActionPreference = 'Stop'
$flutterRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
$projectFile = Join-Path $repositoryRoot 'NexPlayAPI.csproj'
$apiUrl = 'http://127.0.0.1:5290/api/juegos/'
$apiBaseUrl = 'http://127.0.0.1:5290'

$adbCommand = Get-Command adb -ErrorAction SilentlyContinue
$adbPath = if ($adbCommand) { $adbCommand.Source } else { $null }
if (-not $adbPath) {
    $sdkRoots = @($env:ANDROID_SDK_ROOT, $env:ANDROID_HOME, (Join-Path $env:LOCALAPPDATA 'Android\Sdk'))
    foreach ($sdkRoot in $sdkRoots) {
        if ($sdkRoot) {
            $candidate = Join-Path $sdkRoot 'platform-tools\adb.exe'
            if (Test-Path $candidate) {
                $adbPath = $candidate
                break
            }
        }
    }
}
if (-not $adbPath) {
    throw 'No se encontró adb. Instala Android SDK Platform-Tools y conecta el teléfono por USB con Depuración USB habilitada.'
}

$devices = @(& $adbPath devices | Select-String '^\S+\s+device$' | ForEach-Object { ($_ -split '\s+')[0] })
if (-not $DeviceId) {
    if ($devices.Count -ne 1) {
        throw "Se esperaba exactamente un teléfono Android autorizado; se encontraron $($devices.Count). Pasa su serial con -DeviceId."
    }
    $DeviceId = $devices[0]
} elseif ($devices -notcontains $DeviceId) {
    throw "El dispositivo '$DeviceId' no está conectado o no autorizó Depuración USB."
}

$adbArgs = @('-s', $DeviceId)
$backendProcess = $null
try {
    $null = Invoke-WebRequest $apiUrl -UseBasicParsing -TimeoutSec 4
} catch {
    $dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
    if (-not $dotnet) {
        throw 'No se encontró dotnet para iniciar la API.'
    }

    $logDirectory = Join-Path $flutterRoot '.dart_tool'
    New-Item -ItemType Directory -Path $logDirectory -Force | Out-Null
    $stdoutLog = Join-Path $logDirectory 'nexplay-api.stdout.log'
    $stderrLog = Join-Path $logDirectory 'nexplay-api.stderr.log'
    $arguments = @('run', '--project', "`"$projectFile`"", '--launch-profile', 'http')
    $backendProcess = Start-Process -FilePath $dotnet.Source -ArgumentList $arguments `
        -WorkingDirectory $repositoryRoot -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput $stdoutLog -RedirectStandardError $stderrLog

    $deadline = (Get-Date).AddSeconds(90)
    $apiReady = $false
    while ((Get-Date) -lt $deadline) {
        if ($backendProcess.HasExited) {
            $details = if (Test-Path $stderrLog) { Get-Content $stderrLog -Raw } else { '' }
            throw "La API terminó durante el arranque. $details"
        }
        try {
            $null = Invoke-WebRequest $apiUrl -UseBasicParsing -TimeoutSec 3
            $apiReady = $true
            break
        } catch {
            Start-Sleep -Seconds 1
        }
    }
    if (-not $apiReady) {
        throw "La API no respondió en $apiUrl. Revisa los registros en $logDirectory."
    }
}

& $adbPath @adbArgs reverse tcp:5290 tcp:5290
if ($LASTEXITCODE -ne 0) {
    throw 'No se pudo configurar ADB reverse para el puerto 5290.'
}

$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutter) {
    throw 'No se encontró Flutter en PATH.'
}

Write-Host "API disponible en $apiBaseUrl; ADB reverse activo para $DeviceId."
Push-Location $flutterRoot
try {
    & $flutter.Source run -d $DeviceId "--dart-define=NEXPLAY_API_BASE_URL=$apiBaseUrl"
    exit $LASTEXITCODE
} finally {
    Pop-Location
}