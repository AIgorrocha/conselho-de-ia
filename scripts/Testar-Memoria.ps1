[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$Executavel)
$ErrorActionPreference = 'Stop'
$binaryPath = (Resolve-Path -LiteralPath $Executavel).Path
$testPath = Join-Path ([IO.Path]::GetTempPath()) ('aula24-teste-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testPath | Out-Null
$dataPath = Join-Path $testPath 'dados'
New-Item -ItemType Directory -Path $dataPath | Out-Null
$listener = New-Object Net.Sockets.TcpListener([Net.IPAddress]::Loopback, 0)
$listener.Start()
$port = $listener.LocalEndpoint.Port
$listener.Stop()
$configPath = Join-Path $dataPath 'config.toml'
$configText = "bind = `"127.0.0.1:$port`"`nembedding_provider = `"none`"`n[auto_improve.scheduler]`nenabled = false`n"
[IO.File]::WriteAllText($configPath, $configText, (New-Object Text.UTF8Encoding($false)))
$endpoint = "http://127.0.0.1:$port/mcp"
$script:requestId = 0
$server = $null
$checks = New-Object Collections.Generic.List[string]
function Start-IsolatedServer {
    $start = New-Object Diagnostics.ProcessStartInfo
    $start.FileName = $binaryPath
    $start.Arguments = 'serve --data-dir "' + $dataPath + '" --config "' + $configPath + '" --transport http --bind 127.0.0.1:' + $port + ' --workspace aula --project aurora'
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $start.EnvironmentVariables.Clear()
    foreach ($key in @('SystemRoot','WINDIR','TEMP','TMP')) {
        $value = [Environment]::GetEnvironmentVariable($key, 'Process')
        if ($value) { $start.EnvironmentVariables[$key] = $value }
    }
    $start.EnvironmentVariables['USERPROFILE'] = $testPath
    $start.EnvironmentVariables['LOCALAPPDATA'] = $testPath
    $start.EnvironmentVariables['APPDATA'] = $testPath
    $process = [Diagnostics.Process]::Start($start)
    $script:stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $script:stderrTask = $process.StandardError.ReadToEndAsync()
    return $process
}
function Invoke-Mcp([string]$Method, $Parameters) {
    $script:requestId++
    $payload = @{ jsonrpc = '2.0'; id = $script:requestId; method = $Method; params = $Parameters } | ConvertTo-Json -Depth 30 -Compress
    $response = Invoke-RestMethod -Uri $endpoint -Method Post -ContentType 'application/json' -Headers @{ Accept = 'application/json, text/event-stream' } -Body ([Text.Encoding]::UTF8.GetBytes($payload)) -TimeoutSec 5
    if ($response.error) { throw ($response.error | ConvertTo-Json -Compress) }
    if ($response.result.isError) { throw ($response.result | ConvertTo-Json -Depth 15 -Compress) }
    return $response.result
}
function Wait-Server {
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        if ($server.HasExited) { throw ('Servidor encerrou: ' + $script:stderrTask.Result) }
        try {
            $null = Invoke-Mcp 'initialize' @{ protocolVersion = '2024-11-05'; capabilities = @{}; clientInfo = @{ name = 'aula24-teste'; version = '1' } }
            return
        } catch { Start-Sleep -Milliseconds 200 }
    }
    throw 'Servidor isolado nao respondeu apos 30 tentativas.'
}
function Invoke-MemoryTool([string]$Name, $Arguments) {
    return Invoke-Mcp 'tools/call' @{ name = $Name; arguments = $Arguments }
}
function Assert-OwnedPort {
    $listeners = @(Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction Stop)
    if (@($listeners | Where-Object { $_.OwningProcess -eq $server.Id }).Count -eq 0) {
        throw 'A porta nao pertence ao processo iniciado; nenhuma escrita autorizada.'
    }
}
try {
    $server = Start-IsolatedServer
    Wait-Server
    Assert-OwnedPort
    $checks.Add('initialize')
    $catalog = Invoke-Mcp 'tools/list' @{}
    foreach ($name in @('memory_write_page','memory_query','memory_read_page')) {
        if ($catalog.tools.name -notcontains $name) { throw "Ferramenta ausente: $name" }
    }
    $checks.Add('tools/list')
    $wikiPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'memoria\wiki-modelo'
    $pages = @(Get-ChildItem -LiteralPath $wikiPath -Filter '*.md' -File)
    if ($pages.Count -ne 3) { throw 'Esperadas tres paginas sinteticas.' }
    foreach ($page in $pages) {
        $null = Invoke-MemoryTool 'memory_write_page' @{ workspace = 'aula'; project = 'aurora'; path = $page.Name; body = [IO.File]::ReadAllText($page.FullName) }
    }
    $checks.Add('importacao3')
    $found = Invoke-MemoryTool 'memory_query' @{ workspace = 'aula'; project = 'aurora'; query = 'rascunhos'; answer = $false }
    if (($found | ConvertTo-Json -Depth 30) -notmatch 'decisao-rascunhos') { throw 'Busca nao recuperou decisao sintetica.' }
    $checks.Add('busca')
    $read = Invoke-MemoryTool 'memory_read_page' @{ workspace = 'aula'; project = 'aurora'; path = 'decisao-rascunhos.md' }
    if (($read | ConvertTo-Json -Depth 30) -notmatch 'rascunhos') { throw 'Leitura sem conteudo esperado.' }
    $checks.Add('leitura')
    $server.Kill()
    $server.WaitForExit()
    $server.Dispose()
    $server = Start-IsolatedServer
    Wait-Server
    Assert-OwnedPort
    $read = Invoke-MemoryTool 'memory_read_page' @{ workspace = 'aula'; project = 'aurora'; path = 'decisao-rascunhos.md' }
    if (($read | ConvertTo-Json -Depth 30) -notmatch 'rascunhos') { throw 'Conteudo nao persistiu apos reinicio.' }
    $checks.Add('reinicio')
    if (Test-Path -LiteralPath (Join-Path $dataPath 'auth-token')) { throw 'Teste nao deveria criar credencial.' }
    if ([IO.File]::ReadAllText($configPath) -ne $configText) { throw 'Config do teste mudou inesperadamente.' }
    Write-Output ('OK|checks=' + ($checks -join ',') + '|model_calls=0|global_changes=0')
} finally {
    if ($server) {
        if (-not $server.HasExited) { $server.Kill(); $server.WaitForExit() }
        [IO.File]::WriteAllText((Join-Path $testPath 'servidor.log'), $script:stderrTask.Result)
        $server.Dispose()
    }
    Write-Output "EVIDENCIA_LOCAL=$testPath"
}
