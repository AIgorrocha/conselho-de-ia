# Conselho de IA

Kit público de regras, configurações e conectores para Codex, Claude Code e Grok
CLI. Atualizado em **7 de outubro de 2026**. Cada sessão permanece na plataforma
em que começou, delega trabalho delimitado a subagentes nativos e confere o
resultado com fontes e testes.

[Abrir o site](https://aigorrocha.github.io/conselho-de-ia/) ·
[Ler o método](GUIA.md) · [Ver o diagrama](diagrama/arquitetura-multimodelo.html)

## Papéis e modelos

| Plataforma | Principal | Subagentes nativos |
|---|---|---|
| Codex | `gpt-6.1-sol`, `medium`; `high` para tarefas complexas | `gpt-6-luna`, `high`; `medium` para tarefas simples |
| Claude Code | `claude-opus-5-5`, `medium`; `high` para tarefas complexas | `claude-sonnet-5-5`, `high`; `medium` para tarefas simples |
| Grok CLI | `grok-4.7`, `high`, para volume, pesquisa e normalização | Delegação textual somente leitura, sem redelegação |

Toda sessão principal de trabalho delega ao menos um pacote útil. Até três filhos
simultâneos, dono explícito por arquivo, paralelo para trabalho independente e
sequência para dependências. O condutor integra e testa. Delegação é política de
instrução, não um hook que inicia processos automaticamente.

Revisão cruzada é opcional: Codex pode consultar Opus 5.5 `high`; Claude pode
consultar Sol 6.1 `high`; Grok pode consultar um deles. Revisores são somente
leitura e não redelegam. Fable saiu do fluxo padrão; seus arquivos permanecem
como legado.

## Comece por aqui

1. Leia [GUIA.md](GUIA.md), que explica a divisão de trabalho e os limites.
2. Instale e autentique as CLIs que pretende usar, com sua própria assinatura.
3. Mescle somente os trechos necessários dos exemplos abaixo.
4. Rode a verificação local e valide uma tarefa pequena na sua instalação.

O kit não instala CLIs nem inclui autenticação. Não substitua suas configurações
inteiras pelos exemplos. Não copie configurações privadas para este repositório.
Editar configuração não altera modelo ou esforço de uma sessão já aberta.

O protocolo reutilizável está em `prompts/multimodelo.md`. Pode ser colado na
conversa ou instalado em `~/.codex/prompts/multimodelo.md` se sua versão suporta
prompts personalizados. A presença de `/prompts:multimodelo` no menu do aplicativo
depende do runtime; instalar o arquivo não comprova essa disponibilidade.

## Instalação manual

### Regras

| Arquivo do kit | Destino |
|---|---|
| `regras/AGENTS.md` | `~/.codex/AGENTS.md` |
| `regras/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `regras/grok-rules-routing.md` | `~/.grok/rules/00-routing.md` |

Leia e mescle com as instruções existentes. No Windows, `~` representa o diretório
do usuário. Ajuste os caminhos para sua instalação.

### Configurações e agentes

| Arquivo do kit | Destino ou uso |
|---|---|
| `config/codex-config.toml` | Mesclar em `~/.codex/config.toml` |
| `config/claude-settings.json` | Mesclar os campos públicos em `~/.claude/settings.json` |
| `config/grok-config.toml` | Mesclar em `~/.grok/config.toml` |
| `config/grok-delegation-config.toml` | Perfil isolado em `~/.grok-delegation/config.toml` |
| `config/claude-agents/native-worker.md` | `~/.claude/agents/native-worker.md`, Sonnet em `high` |
| `config/claude-agents/native-worker-medium.md` | `~/.claude/agents/native-worker-medium.md`, Sonnet em `medium` |

No Claude, escolha esses agentes customizados para fixar modelo e esforço, em vez
de um agente embutido que force outro modelo. No Codex, `[agents]` define Luna
como trabalhador nativo padrão. Confira o modelo efetivo nos registros da CLI.
Disponibilidade e nomes podem variar conforme versão e assinatura.

Para agentes Codex nomeados, há exemplos high e medium em `config/codex-agents/`.
Copie-os para `~/.codex/agents/` e use o mecanismo de agentes da sua versão.

### Skills

Copie as pastas ativas de `skills/` para o diretório da ferramenta, por exemplo
`~/.agents/skills/` ou `~/.claude/skills/`:

- `cross-model-memory`: plataforma nativa, delegação e revisão opcional.
- `grok-delegation`: leitura isolada, PTY no Windows, limites e síntese.
- `claude-worker`: chamada delimitada ao Sonnet ou revisão pelo Opus.

O MCP `ai-memory` citado nas regras é opcional e não vem configurado no kit.
Configure seu próprio servidor ou adapte as referências à memória que usa.
Não cole endpoint privado nem credencial nestes exemplos públicos.

### Conector Claude

Copie `bin/claude-worker.ps1` para uma pasta local de scripts. Exemplo de revisão:

```powershell
powershell -NoProfile -File .\bin\claude-worker.ps1 -TaskFile .\pacote.md -Workspace C:\trabalho\projeto -Model claude-opus-5-5 -Effort high -MaxTurns 4 -TimeoutSeconds 180
```

O padrão é somente leitura. `-Write` autoriza escrita apenas com Sonnet, dentro do
workspace atribuído. O prompt segue pela entrada padrão (STDIN), preservando
aspas e acentos no PowerShell 5.1. O conector desativa hooks, MCP e redelegação
para essa chamada. Exige Claude Code instalado e autenticado; ajuste o executável
com `-ClaudeExecutable <caminho-do-binario>` quando necessário. No Windows, use
o `claude.exe` nativo; shims `.cmd`, `.bat` e `.ps1` são recusados.

O contador de turnos do CLI não garante orçamento. O timeout limita o tempo e
retorna `124` ao encerrar o processo iniciado. Confira também resultado,
ferramentas negadas e uso reportado. `--bare` pode desativar a autenticação por
assinatura esperada; não é usado neste conector.

`bin/grok-prompt-clean.py` é um filtro local opcional para quem configura hooks de
memória. O kit não instala hooks nem conecta servidores por conta própria.

## Validação

```powershell
powershell -NoProfile -File .\bin\test-multimodel-routing.ps1
```

O teste padrão confere coerência e proteções sem chamar modelos ou publicar.
Testes sintéticos não comprovam autenticação, disponibilidade, consumo ou
estabilidade da sua instalação. Faça um smoke test delimitado em workspace
descartável antes de usar em trabalho real.

## Publicação

O site estático usa GitHub Pages com a branch `main` e a raiz do repositório.
`index.html` apresenta o kit; `diagrama/arquitetura-multimodelo.html` contém o
diagrama, e o PNG é a exportação da mesma versão. Não há backend, coleta de
formulários nem instalador automático.

## Limites e segurança

- Sem loop entre modelos. Cada pacote tem objetivo, escopo, entrega e teto.
- Claude externo: quatro turnos por padrão, até oito em pacote definido;
  timeout padrão de 180 segundos. Grok: quatro, até seis em volume delimitado,
  com teto de tempo definido por quem chama.
- Dois turnos sem progresso encerram como inconclusivo. Sínteses até 400 palavras.
- Credenciais e dados de clientes ficam fora de Git e dos pacotes de revisão.
- Ações públicas, financeiras, destrutivas ou irreversíveis exigem autorização
  explícita. O kit não concede autorização de commit, push ou deploy.
- Subagentes podem aumentar tokens. Economia depende de medição do custo total,
  incluindo coordenação, tempo humano, retrabalho e risco.

## Referências

[Subagentes do Codex](https://learn.chatgpt.com/docs/agent-configuration/subagents),
[subagentes do Claude Code](https://code.claude.com/docs/en/sub-agents) e
[modelos do Claude Code](https://code.claude.com/docs/en/model-config).
