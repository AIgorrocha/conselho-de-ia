# Static coherence checks for the public multimodel kit. Never calls a model.
# Run from any directory: pwsh -File bin\test-multimodel-routing.ps1
$ErrorActionPreference = 'Stop'

function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

$root = Split-Path -Parent $PSScriptRoot
$files = @{
    codexRules = Join-Path $root 'regras\AGENTS.md'
    claudeRules = Join-Path $root 'regras\CLAUDE.md'
    grokRules = Join-Path $root 'regras\grok-rules-routing.md'
    crossSkill = Join-Path $root 'skills\cross-model-memory\SKILL.md'
    grokSkill = Join-Path $root 'skills\grok-delegation\SKILL.md'
    claudeSkill = Join-Path $root 'skills\claude-worker\SKILL.md'
    fableSkill = Join-Path $root 'skills\fable-advisor\SKILL.md'
    claudeWorker = Join-Path $root 'bin\claude-worker.ps1'
    fableCommand = Join-Path $root 'bin\fable-advisor.cmd'
    codexConfig = Join-Path $root 'config\codex-config.toml'
    claudeConfig = Join-Path $root 'config\claude-settings.json'
    grokConfig = Join-Path $root 'config\grok-config.toml'
    grokIsolated = Join-Path $root 'config\grok-delegation-config.toml'
    codexAgent = Join-Path $root 'config\codex-agents\luna-worker.toml'
    claudeAgentHigh = Join-Path $root 'config\claude-agents\native-worker.md'
    claudeAgentMedium = Join-Path $root 'config\claude-agents\native-worker-medium.md'
}
foreach ($path in $files.Values) {
    Assert-True (Test-Path -LiteralPath $path -PathType Leaf) "Arquivo ausente: $path"
}

$text = @{}
foreach ($key in $files.Keys) { $text[$key] = Get-Content -LiteralPath $files[$key] -Raw }
$claudeConfigObject = Get-Content -LiteralPath $files.claudeConfig -Raw | ConvertFrom-Json

foreach ($rules in @($text.codexRules, $text.claudeRules, $text.crossSkill)) {
    Assert-True ($rules.Contains('grok-4.7')) 'Grok 4.7 ausente no roteamento'
    Assert-True ($rules.Contains('xhigh')) 'Regra de justificativa xhigh ausente'
    Assert-True ($rules.Contains('Fable is a legacy') -or $rules.Contains('Fable é legado')) 'Fable nao marcado como legado'
    Assert-True ([regex]::IsMatch($rules, 'opcional|optional', 'IgnoreCase')) 'Revisao cruzada nao indicada como opcional'
}
Assert-True ($text.codexRules.Contains('gpt-6.1-sol') -and $text.codexRules.Contains('gpt-6-luna')) 'Matriz Codex incorreta'
Assert-True ($text.claudeRules.Contains('claude-opus-5-5') -and $text.claudeRules.Contains('claude-sonnet-5-5')) 'Matriz Claude incorreta'
Assert-True ($text.crossSkill.Contains('Maximum three concurrent children')) 'Limite de tres agentes ausente'
Assert-True ($text.crossSkill.Contains('No loops')) 'Regra sem loops ausente'
Assert-True ($text.codexAgent.Contains('developer_instructions')) 'TOML de agente Codex sem instrucoes'
Assert-True ($text.codexAgent.Contains('gpt-6-luna') -and $text.codexAgent.Contains('high')) 'Agente Codex nao usa Luna high'
foreach ($agent in @($text.claudeAgentHigh, $text.claudeAgentMedium)) {
    Assert-True ($agent.Contains('claude-sonnet-5-5')) 'Agente Claude nao usa Sonnet 5.5'
    Assert-True ($agent.Contains('Agent') -and $agent.Contains('Task')) 'Agente Claude permite delegacao recursiva'
}
Assert-True ($text.claudeAgentHigh.Contains('effort: high')) 'Agente Claude high incorreto'
Assert-True ($text.claudeAgentMedium.Contains('effort: medium')) 'Agente Claude medium incorreto'
Assert-True ($claudeConfigObject.model -eq 'claude-opus-5-5') 'Config Claude nao usa Opus 5.5'
Assert-True ($claudeConfigObject.effortLevel -eq 'medium') 'Config Claude padrao nao e medium'
Assert-True ($claudeConfigObject.env.CLAUDE_CODE_SUBAGENT_MODEL -eq 'claude-sonnet-5-5') 'Subagente Claude incorreto'
Assert-True ($text.codexConfig.Contains('gpt-6.1-sol') -and $text.codexConfig.Contains('gpt-6-luna')) 'Config Codex desatualizada'
Assert-True ($text.grokConfig.Contains('default = "grok-4.7"')) 'Config Grok interativa desatualizada'
Assert-True ($text.grokIsolated.Contains('default = "grok-4.7"')) 'Config Grok isolada desatualizada'
Assert-True ($text.grokSkill.Contains('"--model", "grok-4.7"')) 'Skill Grok sem modelo 4.7'
Assert-True ($text.grokSkill.Contains('tty: true')) 'Skill Grok sem requisito PTY'
Assert-True ($text.grokSkill.Contains('existing subscription OAuth login')) 'Skill Grok nao fixa OAuth de assinatura'
Assert-True ($text.grokSkill.Contains('Never falls back to a paid API key')) 'Skill Grok permite API paga como fallback'
Assert-True ($text.grokSkill.Contains("`$env:USERPROFILE = `$isolatedProfile")) 'Isolamento nao define perfil de usuario'
Assert-True (-not $text.grokSkill.Contains('$env:HOME =')) 'Skill Grok modifica HOME'
Assert-True ($text.fableSkill.Contains('explicitly request Fable')) 'Fable nao limitado a pedido explicito'
Assert-True ((Get-Content -LiteralPath $files.fableCommand -Raw).Contains('LEGADO: use somente quando o usuario pedir Fable explicitamente')) 'Wrapper Fable nao marcado como legado'
Assert-True ($text.claudeWorker.Contains("TimeoutSeconds = 180")) 'Adaptador Claude sem timeout padrao real'
Assert-True ($text.claudeWorker.Contains('$process.Kill()')) 'Adaptador Claude sem corte de processo'
Assert-True ($text.claudeWorker.Contains("'claude-opus-5-5'")) 'Adaptador nao suporta Opus 5.5'
Assert-True ($text.claudeWorker.Contains("'claude-sonnet-5-5'")) 'Adaptador nao suporta Sonnet 5.5'

$noHooksPath = Join-Path $root 'config\claude-nohooks.json'
Assert-True (Test-Path -LiteralPath $noHooksPath) 'Configuracao anti-hooks ausente'
$noHooks = Get-Content -LiteralPath $noHooksPath -Raw | ConvertFrom-Json
Assert-True ($noHooks.disableAllHooks -eq $true) 'Hooks legados nao desativados'
Assert-True ($text.fableCommand.Contains('--settings') -and $text.fableCommand.Contains('claude-nohooks.json')) 'Wrapper legado sem settings anti-hooks'
Assert-True ($text.fableCommand.Contains('--restricted') -and $text.fableCommand.Contains('--max-turns 4')) 'Wrapper legado sem restricao e teto'
$activeText = $text.GetEnumerator() | Where-Object { $_.Key -notin @('fableSkill', 'fableCommand') } | ForEach-Object { $_.Value }
$publicText = ($activeText -join "`n") + (Get-Content -LiteralPath $files.codexConfig -Raw) + (Get-Content -LiteralPath $files.grokConfig -Raw) + (Get-Content -LiteralPath $files.grokIsolated -Raw)
$privatePatterns = @('C:\\Users\\[^\\]+\\', 'claude-fable-5-1', 'api[_-]?key\s*=\s*"[^" ]+"', '100\.\d+\.\d+\.\d+')
foreach ($pattern in $privatePatterns) {
    Assert-True (-not [regex]::IsMatch($publicText, $pattern, 'IgnoreCase')) "Padrao privado ou legado ativo encontrado: $pattern"
}

Write-Output "OK|arquivos_verificados=$($files.Count)|model_calls=0|grok=4.7/high|claude_timeout_default=180"
