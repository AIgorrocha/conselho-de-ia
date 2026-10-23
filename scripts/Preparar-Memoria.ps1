# Launcher do instalador oficial MIT de Fabio Akita, sem copiar seu codigo.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Destino,
    [switch]$Aplicar
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$version = '3.2.0'
$installerHash = '86813bc1dc0e42e24d5ead57e56f3906c991fcd256f2642be959342945dce059'
$release = "https://github.com/akitaonrails/ai-memory/releases/download/v$version"
$destinationPath = [IO.Path]::GetFullPath($Destino)
if (Test-Path -LiteralPath $destinationPath) {
    throw 'Escolha um destino novo. O launcher nao substitui pastas existentes.'
}
Write-Output "PLANO: ai-memory v$version em $destinationPath"
Write-Output 'Sem alterar PATH, registro, servico, MCP ou hooks. Configuracao posterior e interativa.'
if (-not $Aplicar) {
    Write-Output 'Nada alterado ou baixado. Use -Aplicar para baixar e instalar somente o binario oficial.'
    return
}
$downloadPath = Join-Path ([IO.Path]::GetTempPath()) ('aula24-download-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $downloadPath | Out-Null
$installerPath = Join-Path $downloadPath 'install.ps1'
Invoke-WebRequest -UseBasicParsing -Uri "$release/install.ps1" -OutFile $installerPath
Invoke-WebRequest -UseBasicParsing -Uri "$release/install.ps1.sha256" -OutFile "$installerPath.sha256"
$checksum = (Get-Content -LiteralPath "$installerPath.sha256" -Raw).Trim()
if ($checksum -notmatch '^([0-9a-fA-F]{64})\s+\*?install\.ps1$') { throw 'Checksum oficial malformado.' }
$published = $Matches[1].ToLowerInvariant()
$actual = (Get-FileHash -LiteralPath $installerPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($published -ne $installerHash -or $actual -ne $installerHash) { throw 'Checksum do instalador divergente. Nada executado.' }
# O processo filho nao herda configuracao de memoria ou provedores do usuario.
$start = New-Object Diagnostics.ProcessStartInfo
$start.FileName = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$start.Arguments = '-NoProfile -File "' + $installerPath + '"'
$start.UseShellExecute = $false
$start.CreateNoWindow = $true
$start.RedirectStandardOutput = $true
$start.RedirectStandardError = $true
$start.EnvironmentVariables.Clear()
$start.EnvironmentVariables['PATHEXT'] = '.COM;.EXE;.BAT;.CMD'
foreach ($key in @('SystemRoot','WINDIR','TEMP','TMP','PROCESSOR_ARCHITECTURE','PROCESSOR_ARCHITEW6432')) {
    $value = [Environment]::GetEnvironmentVariable($key, 'Process')
    if ($value) { $start.EnvironmentVariables[$key] = $value }
}
$start.EnvironmentVariables['AI_MEMORY_VERSION'] = $version
$start.EnvironmentVariables['AI_MEMORY_INSTALL_DIR'] = $destinationPath
$start.EnvironmentVariables['AI_MEMORY_NO_MODIFY_PATH'] = '1'
$start.EnvironmentVariables['AI_MEMORY_RELEASE_BASE_URL'] = 'https://github.com/akitaonrails/ai-memory/releases'
$process = [Diagnostics.Process]::Start($start)
$stdout = $process.StandardOutput.ReadToEndAsync()
$stderr = $process.StandardError.ReadToEndAsync()
if (-not $process.WaitForExit(180000)) { $process.Kill(); throw 'Instalador excedeu 180 segundos.' }
if ($stdout.Result) { Write-Output $stdout.Result }
if ($process.ExitCode -ne 0) { throw "Instalador oficial falhou: $($process.ExitCode). $($stderr.Result) Downloads em $downloadPath" }
Write-Output "INSTALADO: $destinationPath\ai-memory.exe"
Write-Output 'Proximo passo, somente quando desejar configurar seus agentes: execute setup --plan, revise e depois setup interativamente.'
Write-Output "Instalador verificado preservado em $downloadPath"
