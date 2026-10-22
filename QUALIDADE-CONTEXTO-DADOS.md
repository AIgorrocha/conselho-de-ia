# Qualidade, contexto e dados

Este guia complementa o método do kit. Priorize qualidade, segurança e resultado
verificável antes de reduzir tokens ou tempo. Os exemplos de modelos são opções
de roteamento, não garantias de disponibilidade ou de runtime.

## Escolha o tipo de trabalho

- **Determinístico e repetitivo:** prefira scripts, regras, consultas e testes
  quando a transformação tiver entradas e saídas claras. Use IA para elaborar,
  explicar ou tratar exceções, não para substituir uma validação reproduzível.
- **IA leve:** classificação, extração, resumo ou rascunho delimitado podem ir a
  um trabalhador nativo mais rápido, com fonte, formato e checagem definidos.
- **Complexo ou de alto impacto:** mantenha no condutor da plataforma nativa,
  com esforço maior quando necessário. Exija evidência, revisão proporcional e
  validação humana para decisões jurídicas, financeiras, públicas ou irreversíveis.

## Roteamento e responsabilidade

- Codex: Sol 6.1 conduz; Luna 6 recebe tarefas delimitadas. Claude Code: Opus
  5.5 conduz; Sonnet 5.5 recebe tarefas delimitadas. Use os esforços dos exemplos
  do kit como padrão ajustável, não como ranking absoluto de modelos.
- Grok é opcional para leitura de volume, pesquisa, comparação e normalização.
  Não substitui o condutor nem é autoridade final. Revisão cruzada também é
  opcional e deve responder a uma dúvida concreta.
- O condutor define arquivos, dados permitidos, dono, entrega, critério de prova
  e limite do pacote. Ele integra e verifica o resultado. Delegação descrita em
  instruções não prova que a ferramenta executou um subagente.

## Contexto, memória e bancos

- Memória de longo prazo recupera decisões e contexto entre sessões. É um índice
  de recall, não fonte de verdade para o estado atual do produto ou cliente.
- Banco operacional registra e serve o estado transacional atual. Warehouse
  organiza dados integrados para análise histórica e métricas. Memória vetorial
  recupera trechos semanticamente próximos. Esses papéis são diferentes; não
  trate um como substituto automático do outro.
- RAG (geração com recuperação) encontra material para compor uma resposta.
  Recuperação pode ser incompleta, antiga ou fora de contexto. Verifique a fonte
  original, a data e o registro atual antes de agir.
- Backup de ai-memory antes de atualização deve permitir retorno. Teste a versão
  nova em escopo piloto com dados sintéticos: conexão, gravação, recuperação,
  atribuição de fonte, isolamento entre projetos e restauração. Só depois avalie
  ampliar o uso; atualização bem-sucedida não prova qualidade de recall.

## Conectores, hooks e geração visual

- MCP conectado significa que há uma configuração/conexão disponível. Não prova
  que uma chamada ocorreu, que o conteúdo foi capturado ou que um hook foi
  autorizado. Verifique ferramentas visíveis, chamadas, registros e trust do
  evento separadamente. No Codex, conexão MCP e confiança de hooks são controles
  distintos.
- Higgsfield é uma opção especialista para fluxos visuais de imagem e vídeo.
  Antes de automação via MCP, CLI ou outro conector, confirme o que a conta e o
  plano permitem e como gerações consomem créditos. Não presuma que acesso
  Unlimited ou gratuito na interface web vale para uso automatizado.

## Compare pilotos sem ranking universal

Compare candidatos no mesmo conjunto representativo, com instruções e limites
iguais. Registre critérios antes do teste: correção, cobertura, rastreabilidade,
tempo, custo observado, retrabalho e falhas. Preserve exemplos e condições do
piloto. A decisão vale para aquele uso e contexto; não cria uma classificação
absoluta de modelos nem comprova desempenho em outras tarefas.

## Referências oficiais

- [Subagentes do Codex](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [Subagentes do Claude Code](https://code.claude.com/docs/en/sub-agents) e
  [modelos e esforços](https://code.claude.com/docs/en/model-config)
- [MCP remoto da xAI](https://docs.x.ai/developers/tools/remote-mcp) e
  [documentação do protocolo MCP](https://modelcontextprotocol.io/docs)
- [ai-memory](https://github.com/akitaonrails/ai-memory)
- [Higgsfield MCP e uso de créditos](https://higgsfield.ai/creator-hub/help-center/integrations/what-is-higgsfield-mcp)
