# Roteador experimental para CLIs

Revisao de 08/11/2026. Adaptacao MIT de [gargpratyush/jev-router](https://github.com/gargpratyush/jev-router/tree/38da6b84ea01241bfc41fbddc0928d0f40a703f0), commit fixado `38da6b84ea01241bfc41fbddc0928d0f40a703f0`. Origem: proxies HTTP e lancador Codex desse projeto. [Licenca](windows/LICENSE).

## Estado comprovado

21 testes offline aprovados no Docker Windows PC, imagem Node local fixada,512MiB,1CPU,120s,rede externa desativada, fonte e sistema somente leitura. Recursos proprios removidos ao fim. A prova observa os modelos recebidos pelo provedor simulado, nao apenas argumentos de lancamento.

**Experimental, sem ativacao automatica.** Catalogo da conta, OAuth real, compatibilidade das versoes nativas e uso em sessoes reais ainda exigem verificacao operacional. Nao ha integracao comprovada com Codex App, Grok ou Kimi. Orca pode organizar as CLIs, mas nao torna seus protocolos intercambiaveis.

## Funcionamento

O servidor fica no loopback durante a vida de uma CLI. Cada perfil tem porta e estado separados. Recebe requisicoes, encaminha ao provedor fixado e encerra quando a CLI sai. Nao faz polling nem chamadas JEV.

| Papel declarado | Codex | Claude Code |
| --- | --- | --- |
| high | gpt-6-astra | claude-opus-5-5 |
| medium | gpt-6.1-sol | claude-sonnet-5-5 |
| simple | gpt-6-luna | claude-sonnet-5-5 |

O papel seleciona o modelo somente quando a CLI pede a sentinela `jev-router`. Modelo manual permitido prevalece. Continuacoes Codex usam IDs confirmados pelo provedor, modelo anterior e identidade OAuth do perfil. ID desconhecido, expirado ou de outra identidade e recusado. Uma troca manual num turno novo e permitida.

Isto e roteamento deterministico por papel. Nao classifica automaticamente a complexidade do texto nem detecta ataques. Um classificador JEV pago e uma integracao separada, com conteudo, custo e periodo autorizados.

## Arquivos e limites

- `windows/proxy.mjs`: transporte HTTP, politica de papeis e observacao limitada de IDs.
- `windows/launch.mjs` e `jev-continuous.ps1`: CLI interativa, ambiente restrito e processo nativo, sem shell intermediario.
- `windows/*.test.mjs`: testes com provedor local simulado, sem credenciais reais.

Destinos de producao sao fixos: backend Codex do ChatGPT e Messages da Anthropic. Nao segue redirects nem usa API comercial como fallback de assinatura. Cada provedor recebe sua propria lista de cabecalhos. Nao le `.env` do projeto nem herda chaves API no filho. O processo intermediario nao grava prompts, respostas ou historico; a CLI nativa conserva suas proprias regras de armazenamento.

SSE e encaminhado em bytes. O observador separado guarda apenas IDs confirmados, com limite de256 e validade30min. Trata UTF8 dividido, SSE sem Content-Type e frames `data:`. Corpo maximo2MiB; cabeçalhos/corpo10s; inatividade180s; duracao30min. Atualizacao do token OAuth pode exigir novo perfil para continuacoes antigas.

Loopback nao autentica todos os processos locais. Outro processo da mesma maquina ainda pode causar indisponibilidade. Nao ha credencial local nova gerada pelo kit. Rever esse limite antes de uma ativacao operacional.

## Uso somente apos validar a conta e a CLI

Windows, Node20+ e executavel nativo no PATH. O wrapper remove `NODE_OPTIONS` e `NODE_PATH` antes de iniciar Node. Os exemplos abaixo sao formatos de uso, nao prova de que os modelos estao disponiveis na sua conta:

```powershell
.\windows\jev-continuous.ps1 codex --role medium --catalog 'gpt-6-astra,gpt-6.1-sol,gpt-6-luna' --effort high
.\windows\jev-continuous.ps1 claude --role high --catalog 'claude-opus-5-5,claude-sonnet-5-5' --effort high
```

Nenhuma configuracao global e alterada. Nao substituir lancadores do Orca, mudar o App atual ou reiniciar sessoes em andamento por inferencia.

Testes, sempre em ambiente controlado sem rede externa:

```text
node --test roteadores/windows/proxy.test.mjs roteadores/windows/launch.test.mjs
```

Antes de dizer que esta operacional: verificar uma resposta real do provedor e uma continuacao concluida na superficie escolhida. O evento local `routed` registra a decisao local antes de OAuth; nao prova resposta, autenticacao nem aceite.

Protecao web, TDD, dados e backups: [guia de seguranca e operacao](../SEGURANCA-E-OPERACAO.md).
