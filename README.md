# Conselho de IA

Configuração real de orquestração entre três modelos de IA (um condutor, um modelo
de volume mais barato e um modelo de julgamento raro), sanitizada para uso público.
Se você usa mais de uma IA no seu trabalho e quer parar de copiar e colar a mesma
pergunta em três abas até uma resposta "parecer boa", este kit é o método por trás
disso, pronto para adaptar.

Não é um produto nem uma instalação automática. É um conjunto de arquivos de texto
(regras, configurações e conectores de linha de comando) para você ler, entender e
colar nos lugares certos das suas próprias ferramentas.

## Para quem é isto

Para quem já usa pelo menos duas CLIs de IA diferentes no trabalho (por exemplo
Codex, Claude Code e Grok CLI) e quer que elas sigam uma divisão de papéis
consistente, em vez de cada uma improvisar sozinha. Não é preciso saber programar
para ler o `GUIA.md`; os arquivos em `regras/`, `config/`, `skills/` e `bin/` são
técnicos e exigem alguma familiaridade com terminal e edição de arquivos de
configuração.

## Comece por aqui

1. Leia `GUIA.md` primeiro. Ele explica o método (por que três papéis, por que um
   limite de chamadas, por que você sempre tem a palavra final) sem jargão técnico.
2. Volte para este README para a parte de instalação.

## Pré-requisitos

Você não precisa ter os três, mas cada arquivo deste kit assume uma dessas
ferramentas já instalada:

- **Codex CLI** (ou outro condutor de sua escolha), para os arquivos em
  `regras/AGENTS.md` e `config/codex-config.toml`.
- **Grok CLI** (ou outro modelo de volume), para `regras/grok-rules-routing.md`,
  `config/grok-config.toml`, `config/grok-delegation-config.toml` e
  `skills/grok-delegation/`.
- **Claude Code**, para `regras/CLAUDE.md`, `config/claude-settings.json` e
  `skills/fable-advisor/` e `skills/cross-model-memory/`.
- **PowerShell** no Windows, para rodar `bin/fable-advisor.cmd` e
  `bin/test-multimodel-routing.ps1`. Em Mac/Linux, adapte os caminhos e o `.cmd`
  para o shell que você usa (os comandos internos das CLIs são os mesmos).
- **Python 3**, só se você for usar `bin/grok-prompt-clean.py` (um filtro opcional
  de hook, explicado abaixo).

Nenhuma dessas ferramentas é obrigatória sozinha: use os arquivos que correspondem
às CLIs que você já tem.

## Instalação passo a passo

Isto é colar trechos de texto em arquivos que já existem (ou que a própria
ferramenta cria na primeira vez que você a abre). Nenhum arquivo aqui sobrescreve o
seu automaticamente: você decide o que mesclar.

### 1. Regras de cada CLI (arquivos de instrução)

- Abra `regras/AGENTS.md` deste kit e cole o conteúdo dentro de
  `~/.codex/AGENTS.md` (no Windows, `%USERPROFILE%\.codex\AGENTS.md`). Se o
  arquivo já existir com outro conteúdo, cole no final ou funda as seções.
- Abra `regras/CLAUDE.md` deste kit e cole dentro de `~/.claude/CLAUDE.md`.
- Abra `regras/grok-rules-routing.md` deste kit e salve como
  `~/.grok/rules/00-routing.md` (crie a pasta `rules` se não existir).

### 2. Configuração de cada CLI

Cada arquivo em `config/` é um **trecho**, não o arquivo inteiro. Abra o seu
`config.toml` (ou `settings.json`) existente e cole as chaves dentro, na seção
correspondente. Não substitua o arquivo inteiro pelo daqui.

- `config/codex-config.toml` → mesclar em `~/.codex/config.toml`.
- `config/grok-config.toml` → mesclar em `~/.grok/config.toml` (o perfil do dia a
  dia do Grok CLI).
- `config/grok-delegation-config.toml` → mesclar em `~/.grok-delegation/config.toml`
  (um perfil separado e isolado, usado só quando o condutor chama o Grok por
  conta própria; veja a seção 4).
- `config/claude-settings.json` → mesclar as chaves `env` e `modelSettings` dentro
  de `~/.claude/settings.json`.

### 3. Skills

Copie as três pastas de `skills/` para onde a sua CLI local guarda skills (no
Claude Code, normalmente `~/.claude/skills/`; algumas CLIs também aceitam um
diretório compartilhado do tipo `~/.agents/skills/`, verifique a documentação da
sua ferramenta):

- `skills/grok-delegation/` ensina o condutor a chamar o modelo de volume de forma
  limitada, só leitura, com teto de turnos.
- `skills/fable-advisor/` ensina o condutor a chamar o modelo de julgamento de
  forma pontual, com uma tarefa autocontida por chamada.
- `skills/cross-model-memory/` coordena os três quando a tarefa depende de
  histórico entre sessões. Ela foi escrita citando um MCP de memória específico do
  autor original (`ai-memory`); troque pelo MCP de memória que você usa, ou remova
  essa skill se você não tem um servidor de memória cross-sessão.

### 4. Conectores de linha de comando

- `bin/fable-advisor.cmd` é o script que o condutor chama para acionar o modelo de
  julgamento. Copie para uma pasta no seu `PATH` (por exemplo `~/bin/`) e ajuste o
  caminho do executável dentro do arquivo para onde a sua CLI está instalada.
- `bin/grok-prompt-clean.py` é um filtro opcional: só é necessário se você
  configurar um hook de `UserPromptSubmit` no Grok CLI que encaminha prompts para
  um servidor de memória, e esse servidor usa a primeira linha do prompt como
  título. Se você não tem esse hook, ignore este arquivo.
- `bin/test-multimodel-routing.ps1` é um teste de coerência: confere se os
  arquivos de regra, skill e config deste kit continuam consistentes entre si
  (mesmos valores de esforço, mesmos limites de turno, mesmas flags de segurança).
  Rode com:

  ```powershell
  pwsh -File bin\test-multimodel-routing.ps1
  ```

  ou, no PowerShell padrão do Windows:

  ```powershell
  powershell -File bin\test-multimodel-routing.ps1
  ```

  A maior parte do teste roda sozinha, só lendo os arquivos deste kit, sem
  precisar de nenhuma CLI instalada. A última seção do teste é opcional: ela só
  roda de verdade se você já tiver o Grok CLI instalado e a regra do passo 1 copiada
  para `~/.grok/rules/00-routing.md`; caso contrário, ela avisa e pula sem falhar o
  teste.

### 5. O diagrama

`diagrama/arquitetura-real-codex.html` é um resumo visual de todo o fluxo (papéis,
setas de quem chama quem, limites de turno, o que exige autorização humana). Abra
o `.html` em qualquer navegador. Não precisa de servidor nem de internet.

## Mapa dos arquivos

```
conselho-de-ia/
  README.md                      este arquivo: instalação
  GUIA.md                         o método, em linguagem simples
  regras/
    CLAUDE.md                    cole em ~/.claude/CLAUDE.md
    AGENTS.md                    cole em ~/.codex/AGENTS.md
    grok-rules-routing.md        cole em ~/.grok/rules/00-routing.md
  config/
    codex-config.toml            trecho para ~/.codex/config.toml
    grok-config.toml             trecho para ~/.grok/config.toml
    grok-delegation-config.toml  trecho para ~/.grok-delegation/config.toml
    claude-settings.json         trecho para ~/.claude/settings.json
  skills/
    grok-delegation/SKILL.md
    fable-advisor/SKILL.md
    cross-model-memory/SKILL.md
  bin/
    fable-advisor.cmd
    test-multimodel-routing.ps1
    grok-prompt-clean.py
  diagrama/
    arquitetura-real-codex.html
    arquitetura-real-codex.png    (atenção: veja a nota abaixo)
```

## Nota sobre o diagrama PNG

`diagrama/arquitetura-real-codex.png` é uma versão exportada anteriormente e está
desatualizada em relação ao `.html` ao lado (por exemplo, ele mostra o modelo de
volume fixo em esforço máximo o tempo todo, enquanto a versão atual usa esforço
alto como padrão e o máximo só em tarefa complexa). Use o `.html` como referência
principal. Se quiser um PNG atualizado, abra o `.html` num navegador e tire um
print da tela, ou exporte de novo a partir dele.

## O que este kit não faz

- Não instala nenhuma CLI para você. Assume que Codex, Grok CLI e/ou Claude Code
  já estão instalados e autenticados na sua própria assinatura.
- Não inclui nenhuma credencial, chave de API, endereço de servidor ou dado de
  cliente. Tudo isso foi removido da configuração original.
- Não é uma cópia idêntica da configuração privada de ninguém; é uma versão
  generalizada dela.
