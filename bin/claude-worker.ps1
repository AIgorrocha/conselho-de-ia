#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$TaskFile,
    [Parameter(Mandatory)][string]$Workspace,
    [switch]$Write,
    [ValidateRange(1, 8)][int]$MaxTurns = 4,
    [ValidateRange(1, 1800)][int]$TimeoutSeconds = 180,
    [ValidateSet('claude-sonnet-5-5', 'claude-opus-5-5')][string]$Model = 'claude-sonnet-5-5',
    [ValidateSet('medium', 'high')][string]$Effort = 'high',
    [string]$ClaudeExecutable,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$taskPath = Resolve-Path -LiteralPath $TaskFile -ErrorAction SilentlyContinue
$workspacePath = Resolve-Path -LiteralPath $Workspace -ErrorAction SilentlyContinue
if (-not $taskPath -or -not (Test-Path -LiteralPath $taskPath -PathType Leaf)) {
    throw 'TaskFile inexistente ou invalido.'
}
if (-not $workspacePath -or -not (Test-Path -LiteralPath $workspacePath -PathType Container)) {
    throw 'Workspace inexistente ou invalido.'
}
$TaskFile = $taskPath.Path
$Workspace = $workspacePath.Path

if ($Write -and $Model -eq 'claude-opus-5-5') {
    throw 'Opus 5.5 e revisor somente leitura; -Write nao e permitido.'
}

$runningOnWindows = [Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT
$shimExtensions = @('.ps1', '.cmd', '.bat')
if ($ClaudeExecutable) {
    $resolvedClaude = Resolve-Path -LiteralPath $ClaudeExecutable -ErrorAction SilentlyContinue
    if (-not $resolvedClaude -or -not (Test-Path -LiteralPath $resolvedClaude -PathType Leaf)) {
        throw 'ClaudeExecutable precisa apontar para um arquivo executavel existente.'
    }
    $claudeExe = $resolvedClaude.Path
}
else {
    $claudeExe = $null
    $nativeNames = if ($runningOnWindows) { @('claude.exe') } else { @('claude') }
    foreach ($nativeName in $nativeNames) {
        $nativeCommand = Get-Command $nativeName -CommandType Application -ErrorAction SilentlyContinue |
            Where-Object { $shimExtensions -notcontains [IO.Path]::GetExtension($_.Source).ToLowerInvariant() } |
            Select-Object -First 1
        if ($nativeCommand) { $claudeExe = $nativeCommand.Source; break }
    }
    if (-not $claudeExe -and $runningOnWindows -and $env:USERPROFILE) {
        $userBinary = Join-Path $env:USERPROFILE '.local\bin\claude.exe'
        if (Test-Path -LiteralPath $userBinary -PathType Leaf) { $claudeExe = $userBinary }
    }
}
if (-not $claudeExe -or -not (Test-Path -LiteralPath $claudeExe -PathType Leaf)) {
    throw 'Claude CLI nativo nao encontrado. Use -ClaudeExecutable com o binario nativo; shims .ps1, .cmd e .bat nao sao suportados.'
}
$claudeExtension = [IO.Path]::GetExtension($claudeExe).ToLowerInvariant()
if ($shimExtensions -contains $claudeExtension) {
    throw "ClaudeExecutable aponta para shim $claudeExtension. ProcessStartInfo exige o binario nativo, no Windows normalmente claude.exe."
}
if ($runningOnWindows -and $claudeExtension -ne '.exe') {
    throw 'No Windows, ClaudeExecutable deve apontar para claude.exe nativo, nao para um shim.'
}

$tools = @('Read', 'Glob', 'Grep')
$permissionMode = 'dontAsk'
if ($Write) {
    $tools += @('Edit', 'Write')
    $permissionMode = 'acceptEdits'
}
if ($DryRun) {
    [pscustomobject]@{
        model = $Model; effort = $Effort; workspace = $Workspace
        claudeExecutable = $claudeExe
        tools = $tools; permissionMode = $permissionMode
        maxTurns = $MaxTurns; timeoutSeconds = $TimeoutSeconds
        write = [bool]$Write
    } | ConvertTo-Json
    exit 0
}

$taskContent = Get-Content -LiteralPath $TaskFile -Raw -Encoding utf8
$mode = if ($Write) { 'leitura e edicao' } else { 'somente leitura' }
$prompt = @"
Escopo restrito: Workspace=$Workspace. Leia e, quando autorizado, edite apenas arquivos dentro deste workspace.
Ferramentas permitidas: $($tools -join ', '). Modo: $mode. Nao solicite permissao alem das listadas.
Fim verificavel: responda iniciando com 'CONCLUIDO:' ou 'BLOQUEADO:'. Resposta final ate 400 palavras.

Tarefa:
$taskContent
"@

$envNames = @('ANTHROPIC_API_KEY', 'ANTHROPIC_AUTH_TOKEN', 'ANTHROPIC_BASE_URL')
$envBackup = @{}
foreach ($name in $envNames) { $envBackup[$name] = [Environment]::GetEnvironmentVariable($name, 'Process') }
$oldOutputEncoding = $OutputEncoding
$oldConsoleEncoding = [Console]::OutputEncoding
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('claude-worker-' + [guid]::NewGuid().ToString('N'))
$mcpConfig = Join-Path $tempRoot 'mcp-empty.json'
$settingsJson = Join-Path $tempRoot 'settings-nohooks.json'
$exitCode = 1

Push-Location -LiteralPath $Workspace
try {
    New-Item -ItemType Directory -Path $tempRoot | Out-Null
    Set-Content -LiteralPath $mcpConfig -Value '{"mcpServers":{}}' -Encoding Ascii
    Set-Content -LiteralPath $settingsJson -Value '{"disableAllHooks":true}' -Encoding Ascii
    $argsList = @(
        '--restricted', '--strict-mcp-config', '--mcp-config', $mcpConfig,
        '--no-chrome', '--no-session-persistence', '--settings', $settingsJson,
        '--max-turns', "$MaxTurns", '--output-format', 'json',
        '--model', $Model, '--effort', $Effort,
        '--tools', ($tools -join ','), '--allowedTools', ($tools -join ','),
        '--disallowedTools', 'Bash,PowerShell,WebFetch,WebSearch,Task,Agent,Skill,NotebookEdit',
        '--permission-mode', $permissionMode, '-p'
    )
    $OutputEncoding = $utf8NoBom
    [Console]::OutputEncoding = $utf8NoBom
    foreach ($name in $envNames) { [Environment]::SetEnvironmentVariable($name, $null, 'Process') }

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $claudeExe
    $startInfo.Arguments = (($argsList | ForEach-Object { '"' + [string]$_ + '"' }) -join ' ')
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.WorkingDirectory = $Workspace
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.StandardOutputEncoding = $utf8NoBom
    $startInfo.StandardErrorEncoding = $utf8NoBom

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    if (-not $process.Start()) { throw 'Nao foi possivel iniciar o Claude CLI.' }
    try {
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        $timer = [System.Diagnostics.Stopwatch]::StartNew()
        $promptBytes = $utf8NoBom.GetBytes($prompt)
        $writeTask = $process.StandardInput.BaseStream.WriteAsync($promptBytes, 0, $promptBytes.Length)
        $writeCompleted = $false
        try { $writeCompleted = $writeTask.Wait($TimeoutSeconds * 1000) } catch { }
        if (-not $writeCompleted) {
            $process.Kill(); $process.WaitForExit(); $exitCode = 124
            [Console]::Error.WriteLine("Claude CLI excedeu TimeoutSeconds=$TimeoutSeconds durante envio do prompt.")
        }
        else {
            $process.StandardInput.Close()
            $remainingMs = [Math]::Max(0, ($TimeoutSeconds * 1000) - [int][Math]::Ceiling($timer.Elapsed.TotalMilliseconds))
            if (-not $process.WaitForExit($remainingMs)) {
                $process.Kill(); $process.WaitForExit(); $exitCode = 124
                [Console]::Error.WriteLine("Claude CLI excedeu TimeoutSeconds=$TimeoutSeconds; processo encerrado.")
            }
            else { $process.WaitForExit(); $exitCode = $process.ExitCode }
        }
        $stdout = $stdoutTask.GetAwaiter().GetResult()
        $stderr = $stderrTask.GetAwaiter().GetResult()
        if ($stdout) { [Console]::Out.Write($stdout) }
        if ($stderr) { [Console]::Error.Write($stderr) }
    }
    finally { $process.Dispose() }
}
finally {
    foreach ($name in $envNames) { [Environment]::SetEnvironmentVariable($name, $envBackup[$name], 'Process') }
    $OutputEncoding = $oldOutputEncoding
    [Console]::OutputEncoding = $oldConsoleEncoding
    Remove-Item -LiteralPath $mcpConfig, $settingsJson -Force -ErrorAction SilentlyContinue
    try { [System.IO.Directory]::Delete($tempRoot) } catch { }
    Pop-Location
}
exit $exitCode
