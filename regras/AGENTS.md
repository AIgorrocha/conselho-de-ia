# Roteamento multimodelo para Codex

Trecho genérico para instruções globais do Codex. Mescle regras, não substitua
seu arquivo completo de configuração. Não copie configurações globais inteiras
para outro computador.

## Modelos e esforços

| Papel | Modelo | Esforço |
|---|---|---|
| Condutor e revisor do Codex | `gpt-6-astra` | `high` |
| Execução média, ou condução quando escolhida | `gpt-6.1-sol` | `high` |
| Subagente nativo | `gpt-6-luna` | `high`, `medium` em tarefa simples delimitada |
| Grok para leitura de volume | `grok-4.7` | `high`, `xhigh` só com justificativa de complexidade |
| Revisor Claude opcional | `claude-opus-5-5` | `high`, somente leitura |

## Delegação nativa

- Fluxo completo escolhido em 23/10/2026: planejamento Opus/Sonnet no Claude,
  plano sanitizado em `PASSAGEM.md`, execução Sol/Luna e testes no Codex App,
  revisão Astra high independente. Sol high conduz essa execução por escolha
  explícita. O padrão pessoal Astra high continua disponível para outras tarefas.
- Não exigir dois fornecedores para toda microtarefa. Alternativa: iniciar no
  Codex e consultar Claude pelo conector existente, com pacote delimitado.
- Toda sessão de trabalho real atribui ao menos uma tarefa útil e delimitada a
  um subagente nativo. Em tarefa pequena, a atribuição pode ser uma verificação.
- O condutor decompõe, escolhe execução paralela apenas para trabalho
  independente e sequencial para dependências, integra, testa e prova o
  resultado. Até três filhos simultâneos.
- Dê a cada trabalhador escopo, resultado verificável, teto de turnos ou tempo
  e propriedade exclusiva dos arquivos que pode editar.
- Folhas e revisores não abrem subagentes nem chamam outro modelo. Não há
  delegação recursiva.
- Delegação é política de instrução, não despacho automático nem hook.
  Configuração nova vale em sessões novas; sessão aberta mantém seu modelo.

## Grok e revisão cruzada

- Use Grok 4.7 high para leitura massiva, pesquisa, normalização, comparação e
  lacunas verificáveis. Delegação textual é isolada, somente leitura, usa
  assinatura OAuth já autenticada e exige PTY no Windows (`tty: true`). Nunca
  use chave de API paga como fallback. `xhigh` precisa de justificativa
  explícita.
- Revisão cruzada é opcional e somente leitura. Codex pode pedir crítica ao
  Opus 5.5 high quando isso reduzir risco. O revisor devolve achados, o condutor
  confere no código, testes ou fontes e mantém a decisão final.
- Fable é legado. Não faz parte do fluxo padrão.

## Memória comum obrigatória

- ai-memory é parte obrigatória desta arquitetura; instalação e organização
  pertencem à próxima aula. Modelo público em `memoria/` não é servidor instalado.
- MCP conecta cada cliente compatível e autorizado. Não transfere conversa,
  permissões ou execução automaticamente. Declare o escopo correto.
- `memory_query` recupera histórico e `memory_read_page` lê a decisão completa.
  Confronte com fontes atuais. `memory_message_send` só envia a outro projeto
  com autorização humana explícita. Memória não é mensageria.
- Namespace não constitui isolamento de segurança. Separe dados empresariais
  conforme identidade, instância e permissões efetivas. Nunca grave segredos.
- Sem memória configurada, declare a etapa pendente e use passagem manual no
  ensaio. Não declare a arquitetura completa instalada. Providers LLM e
  consolidação generativa são opcionais; a camada de memória é obrigatória.

## Limites

- Claude externo: quatro turnos por padrão, máximo oito apenas para pacote
  delimitado, com timeout do chamador. Grok: quatro por padrão, máximo seis
  para volume com universo e resultado mensuráveis.
- Uma chamada por subtarefa. Só repetir após falha verificável ou lacuna
  objetiva; reduzir o escopo. Duas tentativas sem progresso encerram como
  inconclusivas.
- Sem loop, `max` ou `ultra` por padrão. Nenhum modelo é autoridade final.
- Humano define objetivo, risco e proibições. Ação irreversível, pública,
  financeira, jurídica, destrutiva ou de identidade exige autorização explícita.
- Envie apenas contexto necessário. Nunca inclua segredos, dados de cliente ou
  caminho pessoal em pacote público.
