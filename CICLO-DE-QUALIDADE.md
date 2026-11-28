# Ciclo de qualidade e condutor leve

Dois hábitos que seguram a qualidade de uma sessão longa com subagentes. Valem
no Claude Code e no Codex. Tarefa trivial dispensa os dois.

## 1. O ciclo: implementador, revisor, crítico

Em mudança de risco médio ou alto (código, configuração ou documento que vai
para outra pessoa), o trabalho passa por três papéis.

| Papel | Quem faz | O que entrega |
|---|---|---|
| Implementador | Um subagente | A mudança, com teste |
| Revisor | Outro agente, de contexto limpo e somente leitura | `VEREDITO: APROVADO` ou `VEREDITO: REPROVADO`, com arquivo e linha de cada achado |
| Crítico | O condutor da sessão | Confere a revisão, roda o teste e decide o aceite |

Regras do ciclo:

- O revisor recebe os arquivos alterados e os critérios de aceite numerados.
  Sem critério escrito, ele revisa só contra o objetivo declarado e avisa.
- Cada achado traz arquivo, linha e o trecho literal. Sem trecho, não é achado.
- Critério que só um teste confirma entra como "não verificado", nunca como aprovado.
- Reprovou: os achados voltam para correção. No máximo 2 voltas. Reprovou de
  novo: o condutor para e relata ao humano.
- O revisor nunca corrige e nunca dá o aceite final. Um revisor que conserta
  passa a defender o próprio conserto.
- O ciclo não é loop autônomo. Loop sem teto de ciclos, de tempo e de custo não
  começa.

Agentes do kit para o papel de revisor:

| Ferramenta | Arquivo do kit | Destino | Como o "somente leitura" é garantido |
|---|---|---|---|
| Claude Code | `config/claude-agents/native-reviewer.md` | `~/.claude/agents/native-reviewer.md` | O agente só tem as ferramentas de ler e buscar |
| Codex | `config/codex-agents/astra-reviewer.toml` | `~/.codex/agents/astra-reviewer.toml` | Por instrução; confira na sua versão se há modo de leitura |

Agente novo só aparece em sessão nova.

### Pedido pronto

```text
Antes de me dizer que está pronto, passe esta mudança pelo ciclo de qualidade:
1. Escreva os critérios de aceite numerados.
2. Entregue os arquivos alterados e os critérios ao revisor somente leitura.
3. Se o veredito for REPROVADO, corrija os achados e peça nova revisão.
   No máximo 2 voltas. Reprovou de novo: pare e me mostre os achados.
4. Com veredito APROVADO, rode você mesmo o teste e me mostre a saída.
Mostre o veredito de cada rodada, não só o final.
```

## 2. Condutor leve

A janela de contexto é a memória de trabalho da conversa. Quanto mais cheia,
mais a IA esquece o começo e erra. Por isso o condutor delega leitura de volume
e implementação: quem enche a janela é o subagente, que devolve só o resumo.

- Acompanhe o uso da janela do condutor. O limite de 40% usado aqui é um valor
  de calibragem, não uma lei: o ponto certo varia por modelo.
- Passou do limite: feche a etapa, registre o estado e o próximo passo na
  memória e delegue o resto, ou abra conversa nova com a passagem de bastão.
- No Claude Code, a compactação automática pode ficar na metade da janela do
  modelo (chave `autoCompactWindow` em `~/.claude/settings.json`).
- Delegar poupa a janela do condutor, não o limite de uso da assinatura. Dez
  subagentes gastam dez vezes. Delegar só para deslocar token não vale.

### Pedido pronto

```text
Quanto da janela de contexto esta conversa já usou? Se você não tiver o
número exato, diga que é estimativa. Se passou de 40%, feche a etapa atual,
registre na memória o estado e o próximo passo, e me diga se vale continuar
aqui delegando o resto ou abrir conversa nova.
```

## Limites

Este arquivo descreve um modo de trabalhar. Ele não instala nada sozinho, e a
configuração não prova a execução: confira o modelo e o agente efetivos na
atividade do aplicativo. Nomes de modelos e de chaves mudam com a versão.
