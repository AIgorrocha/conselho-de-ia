# Teste de coerencia do kit "conselho de IA".
#
# Verifica que os arquivos de regra, skill e config do kit continuam
# consistentes entre si (mesmos valores de esforco, mesmos limites de turno,
# mesmas flags de seguranca). Nao instala nada e nao chama nenhum modelo,
# exceto na secao final opcional, que so roda se voce ja tiver o Grok CLI
# instalado e as regras deste kit copiadas para ~/.grok/rules/.
#
# Rode a partir de qualquer lugar: o script acha a raiz do kit sozinho.
#
# Uso: pwsh -File bin\test-multimodel-routing.ps1

$ErrorActionPreference = "Stop"

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

$kitRoot = Split-Path -Parent $PSScriptRoot

$codexRulesPath = Join-Path $kitRoot "regras\AGENTS.md"
$claudeRulesPath = Join-Path $kitRoot "regras\CLAUDE.md"
$grokSkillPath = Join-Path $kitRoot "skills\grok-delegation\SKILL.md"
$fableSkillPath = Join-Path $kitRoot "skills\fable-advisor\SKILL.md"
$grokRulePath = Join-Path $kitRoot "regras\grok-rules-routing.md"
$grokConfigPath = Join-Path $kitRoot "config\grok-config.toml"
$grokDelegationConfigPath = Join-Path $kitRoot "config\grok-delegation-config.toml"
$fableCommandPath = Join-Path $kitRoot "bin\fable-advisor.cmd"

$requiredFiles = @(
    $codexRulesPath,
    $claudeRulesPath,
    $grokSkillPath,
    $fableSkillPath,
    $grokRulePath,
    $grokConfigPath,
    $grokDelegationConfigPath,
    $fableCommandPath
)

foreach ($path in $requiredFiles) {
    Assert-True (Test-Path -LiteralPath $path) "Arquivo obrigatorio ausente: $path"
}

$codexRules = Get-Content -LiteralPath $codexRulesPath -Raw
$claudeRules = Get-Content -LiteralPath $claudeRulesPath -Raw
$grokSkill = Get-Content -LiteralPath $grokSkillPath -Raw
$fableSkill = Get-Content -LiteralPath $fableSkillPath -Raw
$grokRule = Get-Content -LiteralPath $grokRulePath -Raw
$grokConfig = Get-Content -LiteralPath $grokConfigPath -Raw
$grokDelegationConfig = Get-Content -LiteralPath $grokDelegationConfigPath -Raw
$fableCommand = Get-Content -LiteralPath $fableCommandPath -Raw

Assert-True ($codexRules.Contains("## Orçamento de delegação externa")) "Orçamento ausente no arquivo do Codex"
Assert-True ($claudeRules.Contains("### Orçamento de delegação externa")) "Orçamento ausente no arquivo do Claude"
Assert-True ($grokSkill.Contains('$maxTurns = 4')) "Grok sem teto padrão de 4 turnos"
Assert-True ($grokSkill.Contains("Six turns is the absolute ceiling")) "Grok sem teto absoluto de 6 turnos"
Assert-True ($grokSkill.Contains("--output-format")) "Grok sem saída JSON para métricas"
Assert-True ($grokSkill.Contains('$env:GROK_MEMORY = "0"')) "Grok delegado ainda carrega memória de sessão"
Assert-True ($grokSkill.Contains('tty: true')) "Grok delegado sem PTY obrigatório no Codex Windows"
Assert-True ($grokSkill.Contains("'--model', 'grok-4.6'")) "Grok delegado sem modelo fixo"
Assert-True ($grokSkill.Contains("'--reasoning-effort', `$reasoningEffort")) "Grok delegado sem esforço parametrizado"
Assert-True ($grokSkill.Contains("if (`$isComplex) { 'xhigh' } else { 'high' }")) "Grok delegado sem padrão high / xhigh só complexo"
Assert-True ($grokSkill.Contains("'--permission-mode', 'plan'")) "Grok delegado sem modo plan"
Assert-True ($grokSkill.Contains("'--sandbox', 'read-only'")) "Grok delegado sem sandbox read-only"
Assert-True ($grokSkill.Contains("'--no-subagents'")) "Grok delegado permite subagentes"
Assert-True ($grokSkill.Contains("'--cwd', `$workingDirectory")) "Grok delegado sem cwd isolado"
Assert-True ($grokSkill.Contains("`$grokArgs += @('--tools', `$toolAllowlist)")) "Grok delegado sem allowlist condicional"
Assert-True ($grokSkill.Contains('"web_search,web_fetch"')) "Grok web com tools divergentes"
Assert-True ($grokSkill.Contains('"read_file,grep,list_dir"')) "Grok de evidência com tools divergentes"
Assert-True ($grokSkill.Contains('"run_terminal_cmd,grep,read_file,search_replace,list_dir,web_search,web_fetch,todo_write,task"')) "Grok sem denylist integral para revisão sem tools"
Assert-True ($grokSkill.Contains("`$grokArgs += @('--disallowed-tools', `$allBuiltInTools)")) "Grok sem aplicação da denylist integral"
Assert-True (-not $grokSkill.Contains("'--tools', `$toolAllowlist,")) "Grok mantém allowlist vazia na lista base"
Assert-True ($grokSkill.Contains('$env:RUST_LOG = "off"')) "Grok delegado sem saída JSON silenciosa"
Assert-True ($grokSkill.Contains('$env:GROK_HOME = $delegationRoot')) "Grok delegado sem GROK_HOME isolado"
Assert-True ($grokSkill.Contains('$env:GROK_AUTH_PATH = "~\.grok\auth.json"')) "Grok delegado sem referência OAuth existente"
Assert-True ($grokSkill.Contains('Never point `--cwd` at the source repository')) "Grok delegado ainda pode receber cwd do repositório"
Assert-True ($grokSkill.Contains('Remove-Item "Env:$sensitiveName"')) "Grok delegado não limpa variáveis sensíveis"
Assert-True ($codexRules.Contains('terminal PTY (`tty: true`)')) "Regra PTY ausente no arquivo do Codex"
Assert-True ($claudeRules.Contains('terminal PTY (`tty: true`)')) "Regra PTY ausente no arquivo do Claude"
Assert-True ($grokConfig.Contains("[features]`ntelemetry = false") -or $grokConfig.Contains("[features]`r`ntelemetry = false")) "Telemetria Grok não desativada"
Assert-True ($grokConfig.Contains("[telemetry]`ntrace_upload = false") -or $grokConfig.Contains("[telemetry]`r`ntrace_upload = false")) "Trace upload Grok não desativado"
Assert-True (-not $grokConfig.Contains('[privacy]')) "Config Grok mantém chave privacy inválida"
Assert-True ($grokDelegationConfig.Contains('codebase_indexing = false')) "Perfil Grok isolado mantém indexação"
Assert-True ($grokDelegationConfig.Contains('remote_fetch = false')) "Perfil Grok isolado mantém fetch remoto implícito"
Assert-True ($grokDelegationConfig.Contains('load_envrc = false')) "Perfil Grok isolado carrega envrc"
Assert-True ($grokDelegationConfig.Contains('trace_upload = false')) "Perfil Grok isolado mantém trace upload"
Assert-True ($grokDelegationConfig.Contains('~/.agents/skills')) "Perfil Grok isolado não ignora skills globais"
foreach ($config in @($grokConfig, $grokDelegationConfig)) {
    Assert-True ($config -match '(?m)^default\s*=\s*"grok-4\.6"$') "Config Grok sem modelo padrão 4.6"
    Assert-True ($config -match '(?m)^default_reasoning_effort\s*=\s*"high"$') "Config Grok sem esforço padrão high"
}
$claudeBlock = [regex]::Match($grokConfig, '(?ms)^\[compat\.claude\]\s*(.*?)(?=^\[|\z)').Groups[1].Value
$codexBlock = [regex]::Match($grokConfig, '(?ms)^\[compat\.codex\]\s*(.*?)(?=^\[|\z)').Groups[1].Value
foreach ($compatField in @('skills', 'rules', 'agents', 'mcps', 'hooks', 'sessions')) {
    Assert-True ($claudeBlock -match "(?m)^$compatField\s*=\s*false$") "Compat Claude Grok ativa: $compatField"
    Assert-True ($codexBlock -match "(?m)^$compatField\s*=\s*false$") "Compat Codex Grok ativa: $compatField"
}
Assert-True ($codexRules.Contains("Variance: execução direta em terminal dedicado")) "Variance ausente no arquivo do Codex"
Assert-True ($claudeRules.Contains("Variance: execução direta em terminal dedicado")) "Variance ausente no arquivo do Claude"
Assert-True ($grokSkill.Contains("separate Grok Build terminal")) "Skill Grok não separa delegação de terminal dedicado"
Assert-True ($grokRule.Contains("Delegação textual iniciada pelo condutor permanece somente leitura")) "Regra Grok não separa delegação de terminal dedicado"
Assert-True ($fableSkill.Contains("Default output cap is 800 words")) "Fable sem limite de saída"
Assert-True ($fableCommand.Contains("--model claude-fable-5-1")) "Wrapper Fable com modelo incorreto"
Assert-True ($fableCommand.Contains('set "EFFORT=high"')) "Wrapper Fable sem esforço padrão high"
Assert-True ($fableCommand.Contains("--effort %EFFORT%")) "Wrapper Fable sem esforço parametrizado"
Assert-True ($fableCommand.Contains("--no-session-persistence")) "Wrapper Fable persiste sessão"
Assert-True ($fableCommand.Contains("--disallowed-tools Edit Write")) "Wrapper Fable sem bloqueio de escrita"

$forbiddenDash = [regex]"[$([char]0x2013)$([char]0x2014)]"
foreach ($text in @($codexRules, $claudeRules, $grokSkill, $fableSkill, $grokRule)) {
    Assert-True (-not $forbiddenDash.IsMatch($text)) "Travessão encontrado em configuração do kit"
}

Write-Output "OK|arquivos_verificados=$($requiredFiles.Count)|grok_default_turns=4|grok_max_turns=6|literal_tokens=0"

# --- Secao opcional: so roda se voce ja instalou o Grok CLI e copiou
# regras/grok-rules-routing.md para ~/.grok/rules/00-routing.md. Esta parte
# nao falha o script se o Grok nao estiver instalado; ela so avisa.
$grokExecutable = Join-Path $env:USERPROFILE ".grok\bin\grok.exe"
$liveRulePath = Join-Path $env:USERPROFILE ".grok\rules\00-routing.md"

if ((Test-Path -LiteralPath $grokExecutable) -and (Test-Path -LiteralPath $liveRulePath)) {
    try {
        $inspect = (& $grokExecutable inspect --json | Out-String) | ConvertFrom-Json
        $activeGlobalRules = @(
            $inspect.projectInstructions |
                Where-Object { $_.scope -eq "global" -and -not $_.disabled } |
                ForEach-Object { $_.path }
        )
        Assert-True ($activeGlobalRules -contains $liveRulePath) "Regra global de roteamento não carregada pelo Grok CLI instalado"
        Write-Output "OK|grok_cli_live_check=passou"
    } catch {
        Write-Warning "Grok CLI instalado, mas a checagem ao vivo falhou: $($_.Exception.Message)"
    }
} else {
    Write-Output "grok_cli_live_check=pulado (instale o Grok CLI e copie regras/grok-rules-routing.md para ~/.grok/rules/00-routing.md para rodar essa parte)"
}
