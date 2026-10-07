# Roteamento multimodelo para Claude Code

Trecho genérico para `~/.claude/CLAUDE.md` ou `%USERPROFILE%\.claude\CLAUDE.md`.
Mescle as instruções necessárias. Não substitua seu arquivo global completo.

## Modelos e esforços

| Papel | Modelo | Esforço |
|---|---|---|
| Condutor do Claude Code | `claude-opus-5-5` | `medium`, `high` em tarefa complexa |
| Subagente nativo | `claude-sonnet-5-5` | `high`, `medium` em tarefa simples delimitada |
| Grok para leitura de volume | `grok-4.7` | `high`, `xhigh` só com justificativa de complexidade |
| Revisor Codex opcional | `gpt-6.1-sol` | `high`, somente leitura |

## Delegação nativa

- Toda sessão de trabalho real atribui ao menos uma tarefa útil e delimitada a
  um subagente nativo. Para tarefa pequena, delegue uma verificação.
- O condutor decompõe, escolhe execução paralela para tarefas independentes e
  sequencial para dependências, integra, testa e prova o resultado.
- Use agentes de folha com Sonnet 5.5 high ou medium. Eles não podem usar
  `Agent` ou `Task`, nem iniciar chamadas a outros modelos. Máximo de três
  subagentes simultâneos.
- Cada agente recebe objetivo, arquivos próprios, resultado verificável e teto
  de tempo ou turnos. Um arquivo editável tem um único dono.
- Delegação é política de instrução, não execução automática em background.
  Configuração nova vale em sessões novas; sessão aberta mantém seu modelo.

## Grok e revisão cruzada

- Use Grok 4.7 high para leitura massiva, pesquisa, normalização, comparação e
  lacunas verificáveis. Delegação textual usa perfil isolado, somente leitura,
  assinatura OAuth existente e PTY no Windows (`tty: true`). Nunca use chave
  de API paga como fallback. `xhigh` exige justificativa explícita.
- Revisão cruzada é opcional, somente leitura. Claude pode pedir ao Sol 6.1 high
  uma crítica delimitada. O condutor confronta os achados com fonte, código ou
  teste e mantém a decisão final.
- Fable é legado e não faz parte do fluxo padrão.

## Limites

- Claude: quatro turnos por padrão e máximo oito em pacote delimitado. Use o
  adaptador opcional `skills/claude-worker/SKILL.md` para leitura ou escrita
  autorizada com limite real de tempo, padrão de 180 segundos.
- Grok: quatro turnos por padrão, máximo seis para volume com universo e
  resultado mensuráveis. Uma chamada por subtarefa; nova chamada só após falha
  verificável ou lacuna objetiva e com escopo reduzido.
- Sem loop, `max` ou `ultra` por padrão. Duas tentativas sem progresso encerram
  como inconclusivas. Nenhum modelo é autoridade final.
- Ação irreversível, pública, financeira, jurídica, destrutiva ou de identidade
  exige autorização humana explícita. Envie somente contexto necessário.
