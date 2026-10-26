# Conselho de IA

Kit público de orquestração para Codex, Claude Code e Grok CLI: regras,
configurações, delegação, conectores e revisão. Revisão **v2026.10.26**, de
**26 de outubro de 2026**. A plataforma em que o trabalho começa mantém a
condução; trocar de plataforma é uma opção, não uma etapa obrigatória.
É uma preferência de trabalho, não um ranking universal entre fornecedores.

ai-memory é a dependência obrigatória de memória comum. Sua instalação e nossa
camada de integração estão no [pacote separado AI Memory Integração](https://github.com/AIgorrocha/ai-memory-integracao).
O servidor original é o projeto open source de
[Fabio Akita](https://github.com/akitaonrails/ai-memory). O pacote de integração
não é um fork do servidor nem uma instalação automática do Conselho.

[Abrir o site](https://aigorrocha.github.io/conselho-de-ia/) ·
[Ler o método](GUIA.md) · [Ver o diagrama](diagrama/arquitetura-multimodelo.html) ·
[Pacote de memória comum](https://github.com/AIgorrocha/ai-memory-integracao)

O [acervo de memória de 23/10/2026](memoria/README.md) permanece como histórico,
incluindo o preparador Windows e o teste isolado do ai-memory 3.2.0. O material
atual da Aula 2.4 está no pacote separado; conexão, captura e persistência exigem
validação na instalação do aluno.

## Fluxo de trabalho e passagem opcional

1. Comece na plataforma escolhida. No Codex, Astra high conduz por padrão;
   Sol 6.1 pode conduzir quando escolhido. No Claude Code, Opus 5.5 conduz.
2. Atribua objetivo, arquivos, fontes, aceite e limites aos trabalhadores
   nativos: Sol 6.1/Luna 6 no Codex e Sonnet 5.5 no Claude Code.
3. O condutor integra, testa e apresenta evidências. Quando útil, peça revisão
   cruzada consultiva, somente leitura, da versão fixada em contexto separado.
4. Consulte e mantenha ai-memory no escopo autorizado. Ela preserva decisões e
   histórico, sem transferir automaticamente conversa, permissões ou ações.

O exemplo do curso de 23/10/2026 planejava com Opus/Sonnet e passava a execução
para Sol/Luna, com revisão independente Astra high. Essa sequência continua
como opção de estudo, não como obrigação de planejar no Claude e executar no Codex.
Ao trocar de plataforma, fixe plano, fontes, versão, provas e permissões em
`PASSAGEM.md`, encerre a escrita anterior e abra uma sessão nova.

Também é possível começar no Codex App e consultar Claude pelo conector existente
`bin/claude-worker.ps1`. Não é obrigatório usar dois fornecedores em toda
microtarefa. Cada fase preserva sua plataforma e seus subagentes nativos.

## Papéis e modelos

| Plataforma | Principal | Subagentes nativos |
|---|---|---|
| Codex | `gpt-6-astra`, `high`; Sol 6.1 quando escolhido para conduzir | `gpt-6.1-sol`, `high`, para execução média; `gpt-6-luna`, `high`, para tarefas simples |
| Claude Code | `claude-opus-5-5`, `medium`; `high` para tarefas complexas | `claude-sonnet-5-5`, `high`; `medium` para tarefas simples |
| Grok CLI | `grok-4.7`, `high`, para volume, pesquisa e normalização | Delegação textual somente leitura, sem redelegação |

Toda sessão principal de trabalho delega ao menos um pacote útil. Até três filhos
simultâneos, dono explícito por arquivo, paralelo para trabalho independente e
sequência para dependências. O condutor integra e testa. Delegação é política de
instrução, não um hook que inicia processos automaticamente.

Revisão cruzada é opcional e consultiva: Codex pode consultar Opus 5.5 `high`; Claude pode
consultar Astra `high`; Grok pode consultar um deles. Revisores são somente
leitura e não redelegam. Fable saiu do fluxo padrão; seus arquivos permanecem
como legado.

## Prática para alunos

Abra o [exemplo completo de agentes e skills](exemplos/curso-agentes-skills/LEIA-ME.md).
O exemplo de 23/10/2026 começa pelo plano Opus/Sonnet, passa para Sol 6.1 na
execução por escolha explícita, Luna na triagem e Astra na revisão independente.
É uma sequência opcional de estudo. Inclui
árvores, arquivos válidos, prompts, gabarito e passagem de contexto entre plataformas.
A configuração é um exemplo; a execução deve ser confirmada na instalação do aluno.

## Comece por aqui

1. Leia [GUIA.md](GUIA.md), que explica a divisão de trabalho e os limites.
2. Instale e autentique as CLIs que pretende usar, com sua própria assinatura.
3. Mescle somente os trechos necessários dos exemplos abaixo.
4. Prepare a [camada de memória comum no pacote próprio](https://github.com/AIgorrocha/ai-memory-integracao),
   tema da Aula 2.4. Baixar o Conselho não instala o servidor; a arquitetura
   completa exige ai-memory configurado e validado.
5. Rode a verificação local e valide uma tarefa pequena na sua instalação.

O kit não instala CLIs nem inclui autenticação. Não substitua suas configurações
inteiras pelos exemplos. Não copie configurações privadas para este repositório.
Editar configuração não altera modelo ou esforço de uma sessão já aberta.

O protocolo reutilizável está em `prompts/multimodelo.md`. Pode ser colado na
conversa ou instalado em `~/.codex/prompts/multimodelo.md` se sua versão suporta
prompts personalizados. A presença de `/prompts:multimodelo` no menu do aplicativo
depende do runtime; instalar o arquivo não comprova essa disponibilidade.

[Qualidade, contexto e dados](QUALIDADE-CONTEXTO-DADOS.md) complementa o método
com critérios para priorizar qualidade, escolher tarefas por capacidade e validar
memória, RAG, MCP e pilotos sem presumir que configuração prova runtime.

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
de um agente embutido que force outro modelo. No Codex, `[agents]` define Sol
como trabalhador nativo padrão; o agente Luna recebe tarefas simples. Confira o modelo efetivo nos registros da CLI.
Disponibilidade e nomes podem variar conforme versão e assinatura.

Para agentes Codex nomeados, há Sol, Luna e Astra em `config/codex-agents/`.
Copie-os para `~/.codex/agents/` e use o mecanismo de agentes da sua versão.

### Skills

Copie as pastas ativas de `skills/` para o diretório da ferramenta, por exemplo
`~/.agents/skills/` ou `~/.claude/skills/`:

- `cross-model-memory`: planejamento, execução, revisão e memória comum obrigatória.
- `grok-delegation`: leitura isolada, PTY no Windows, limites e síntese.
- `claude-worker`: chamada delimitada ao Sonnet ou revisão pelo Opus.

O ai-memory é obrigatório na arquitetura ensinada e não vem instalado no kit.
MCP (Model Context Protocol, protocolo de contexto e ferramentas) conecta cada
cliente compatível e autorizado ao servidor escolhido. Não conecta qualquer
aplicativo universalmente. Instalação, organização pessoal/empresarial e testes
ficam no [pacote próprio AI Memory Integração](https://github.com/AIgorrocha/ai-memory-integracao).
Não publique endpoints ou credenciais.

### Claude para Codex

O [plugin oficial `openai/codex-plugin-cc`](https://github.com/openai/codex-plugin-cc)
oferece `/codex:rescue` para delegar trabalho e `/codex:transfer` para criar uma
sessão Codex continuável no App/TUI. `/codex:review` é somente leitura e não
implementa o plano. A auditoria local do autor em 23/10/2026 encontrou a versão
1.0.6 instalada e habilitada; isso não comprova disponibilidade no aluno.

Para estudar a passagem opcional de 23/10/2026 com Sol/Luna/Astra, use a passagem
sanitizada e sessão nova no Codex App. Verifique comandos, modelo, esforço e subagentes efetivos
antes de usar o plugin. Não presuma que uma chamada rescue permita toda a cadeia
nativa. Transfer importe somente sessão sintética, sem transcrição privada.
Se o plugin não estiver disponível, use `PASSAGEM.md` manualmente. O plugin não
instala memória nem transfere permissões; ai-memory é uma consulta separada.

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
`index.html` e `diagrama/arquitetura-multimodelo.html` distinguem a orquestração
da dependência externa de memória. O diagrama preserva o exemplo opcional de
passagem de 23/10/2026. O PNG antigo é um registro histórico
de 07/10/2026 e não acompanha as revisões atuais. O site não tem backend nem coleta
de formulários. O preparador Windows legado só instala o binário quando executado
com `-Aplicar`.

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

A revisão tem data e base de comparação; o commit que a entregar deve ser
conferido no histórico Git. Não há promessa de sincronização automática entre
este kit público, instalações pessoais, plugins e servidores dos alunos.
