param([ValidateSet('codex', 'claude')][string]$Cli)
$ErrorActionPreference = 'Stop'
$nodeExecutable = (Get-Command node.exe -CommandType Application -ErrorAction Stop).Source
$savedNodeOptions = [Environment]::GetEnvironmentVariable('NODE_OPTIONS', 'Process')
$savedNodePath = [Environment]::GetEnvironmentVariable('NODE_PATH', 'Process')
try {
    [Environment]::SetEnvironmentVariable('NODE_OPTIONS', $null, 'Process')
    [Environment]::SetEnvironmentVariable('NODE_PATH', $null, 'Process')
    if ($Cli) {
        & $nodeExecutable (Join-Path $PSScriptRoot 'launch.mjs') '--cli' $Cli @args
    } else {
        & $nodeExecutable (Join-Path $PSScriptRoot 'launch.mjs') '--help'
    }
    $nativeExitCode = $LASTEXITCODE
} finally {
    [Environment]::SetEnvironmentVariable('NODE_OPTIONS', $savedNodeOptions, 'Process')
    [Environment]::SetEnvironmentVariable('NODE_PATH', $savedNodePath, 'Process')
}
exit $nativeExitCode
