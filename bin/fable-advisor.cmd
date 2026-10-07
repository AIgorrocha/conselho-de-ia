@echo off
REM LEGADO: use somente quando o usuario pedir Fable explicitamente. Nao faz
REM parte do fluxo padrao, que usa agentes nativos Claude ou revisao opcional.
REM fable-advisor: conector proprio Codex -> Claude Fable.
REM Existe porque conectores comunitarios equivalentes costumam chamar o Claude
REM com as ferramentas de leitura DESLIGADAS no modo revisao (--tools ""), e ai
REM o Claude nao consegue ler o arquivo que deveria criticar e preenche a
REM lacuna, citando algo que nao existe. Aqui a leitura fica ligada e o
REM modelo fica FIXO em claude-fable-5-1; esforco padrao high; segundo
REM argumento so em tarefa complexa (criterio de acionamento do CLAUDE.md
REM global).
REM Uso legado, somente apos pedido explicito: fable-advisor "pergunta" [high|medium]
REM Ajuste o caminho do claude.exe abaixo para a sua instalacao.
setlocal
set "EFFORT=%~2"
if "%EFFORT%"=="" set "EFFORT=high"
if "%~1"=="" (
  echo Uso: fable-advisor "o que voce quer que o Fable analise"
  exit /b 2
)
if not exist "%~dp0..\config\claude-nohooks.json" (
  echo Configuracao de seguranca ausente: config\claude-nohooks.json
  exit /b 2
)
set "ANTHROPIC_API_KEY="
set "ANTHROPIC_AUTH_TOKEN="
set "ANTHROPIC_BASE_URL="
"%USERPROFILE%\.local\bin\claude.exe" -p %1 ^
  --restricted ^
  --settings "%~dp0..\config\claude-nohooks.json" ^
  --model claude-fable-5-1 ^
  --effort %EFFORT% ^
  --permission-mode dontAsk ^
  --max-turns 4 ^
  --tools Read,Glob,Grep ^
  --allowed-tools Read Glob Grep ^
  --disallowed-tools Edit Write NotebookEdit Bash PowerShell WebFetch WebSearch Task Agent Skill ^
  --strict-mcp-config ^
  --no-chrome ^
  --no-session-persistence ^
  --output-format text
