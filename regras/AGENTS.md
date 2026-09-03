# Regras de orquestração multimodelo (versão Codex)

Trecho pronto para colar em `~/.codex/AGENTS.md` (no Windows,
`%USERPROFILE%\.codex\AGENTS.md`). Versão sanitizada e genérica de uma
configuração real em uso. Mantém compatibilidade de conteúdo com
`regras/CLAUDE.md` deste kit: se mudar um runtime, revise o outro.

## Matriz de modelos e orquestração

- O modelo de volume cobre volume, cobertura, pesquisa, comparação e
  localização de lacunas. Começa em modo somente leitura quando entra em um
  fluxo novo. Não aprova nem altera a fonte principal sem escopo explícito.
- O condutor decompõe, atribui responsabilidades, cria ou altera a fonte
  principal, confronta respostas com código, dados, testes e fontes, integra
  resultados e fecha o ciclo. É o condutor padrão.
- O modelo de julgamento é usado somente de forma rara: interpretação do
  conjunto, crítica adversarial, narrativa, copy, experiência humana e
  decisões conceituais difíceis. Não usar para pesquisa volumosa nem autoria
  contínua quando o modelo de volume ou o condutor resolvem com menor custo
  total.
- O humano define objetivo, risco, proibições e autoriza qualquer ação
  irreversível, pública, financeira, jurídica, destrutiva ou de identidade.
  Silêncio não é aprovação.
- Nenhum modelo é autoridade final. Primeiro demonstrar com fonte, código,
  teste, cálculo ou regra, depois julgar.

## Esforço: padrão e exceção

| Papel | Padrão | Só em tarefa complexa |
|---|---|---|
| Condutor | modelo condutor em esforço alto | esforço máximo, só em tarefa complexa |
| Subagente do condutor | modelo de subagente em esforço alto | não sobe |
| Modelo de volume | esforço alto | esforço máximo, só em tarefa complexa |
| Modelo de julgamento | esforço alto | não sobe (esforço máximo proibido por padrão) |
| Subagente do assistente de código local | esforço alto | não sobe |

- Um modelo de subagente mais barato em esforço médio serve apenas para
  volume excepcional, quando o modelo de volume principal não estiver
  disponível.
- Nunca usar esforço máximo por padrão. Evitar enxames de agentes mal
  gerenciados.

## Critério de acionamento (quem chamar e em que esforço)

1. Toda tarefa começa no esforço padrão. Subir é exceção declarada ("esforço
   máximo porque..."), nunca hábito.
2. A tarefa é COMPLEXA, e sobe para o esforço da coluna da direita, quando
   tem pelo menos UM destes sinais: (a) mais de um sistema ou arquivo com
   dependência entre si; (b) não existe gabarito verificável (teste, número,
   fonte) para conferir a resposta; (c) o erro custa retrabalho grande,
   efeito externo ou decisão de arquitetura; (d) a tentativa no padrão
   falhou ou voltou sem veredito.
3. Custo total decide quem é chamado: soma de limite de uso, tempo humano,
   retrabalho esperado, risco de defeito e atraso. Escolher a combinação mais
   barata que entrega resultado aceitável. Subir esforço só quando o custo do
   erro supera o custo do esforço extra.
4. Divisão por natureza do trabalho: modelo de volume quando é volume com
   fim observável (pesquisa, comparação, cobertura, contagem); modelo de
   julgamento quando a dúvida é de julgamento (interpretação do conjunto,
   crítica adversarial, copy, decisão conceitual); condutor fica com busca
   curta, comando de busca local, teste e leitura de poucos arquivos. Delegar
   só para deslocar tokens, sem reduzir custo total, é proibido.
5. Resultado sem veredito, contraditório ou cortado pelo teto não vira
   conclusão: registrar como incompleto e seguir por evidência local.

## Conectores entre modelos

- Esta arquitetura de três papéis é o padrão automático, não uma obrigação.
  O condutor conduz por padrão. Você pode mudar ordem, modelo inicial e dono
  de cada fase.
- O condutor chama o modelo de volume por um conector local (ver
  `skills/grok-delegation/SKILL.md`), CLI oficial, assinatura própria,
  esforço alto (esforço máximo só em tarefa complexa), leitura e limite de
  turnos. Um plugin de acesso rápido fica restrito a perguntas curtas porque
  não expõe limite de turnos nem métricas completas ao condutor.
- O condutor chama o modelo de julgamento pelo conector próprio (ver
  `bin/fable-advisor.cmd`), fixado no modelo e esforço padrão (o segundo
  argumento só muda o esforço em caso excepcional autorizado), com leitura
  local. Um conector comunitário equivalente serve apenas para conselho
  curto, nunca para revisão de arquivo.
- O assistente de código local chama o modelo de volume por um plugin de
  acesso rápido e o condutor por outro plugin oficial. Essas rotas também
  obedecem ao orçamento abaixo.
- A instrução explícita do usuário pode mudar a ordem, o ponto de partida e
  o responsável por cada etapa, inclusive o modelo de julgamento planejar, o
  condutor executar e depois o modelo de volume revisar ou ampliar. Cada
  etapa mantém dono, escopo e fim verificável.
- Toda delegação ao modelo de volume usa esforço alto por padrão, ou esforço
  máximo quando a tarefa atende ao critério de complexa. Não trocar de
  modelo, baixar de esforço nem configurar fallback sem autorização
  explícita.
- No assistente de código local, não informar outro modelo ao conector. Usar
  o padrão global do modelo de julgamento em esforço alto. Subagentes do
  condutor usam o modelo de subagente em esforço alto (seção de agentes na
  configuração).
- Toda chamada externa recebe uma tarefa autocontida, escopo delimitado,
  entrega verificável, limite de tamanho e condições de parada. Enviar
  somente o contexto necessário e nunca incluir segredos.
- O modelo de volume e o modelo de julgamento começam em leitura. Escrita
  pelo modelo de julgamento exige autorização explícita. O modelo de volume
  não altera a fonte principal por meio do conector textual.
- Por padrão, permitir no máximo uma chamada externa por subtarefa. Uma
  segunda chamada exige falha verificável, lacuna objetiva ou pedido
  explícito. Fluxos diferentes definidos pelo usuário são permitidos, mas
  ping-pong recursivo e delegação sem dono continuam proibidos.
- O resultado volta ao condutor, que confronta com fonte, código, dados e
  testes antes de aceitar. Memória compartilhada continua no seu servidor de
  memória cross-sessão (ver nota em `skills/cross-model-memory/SKILL.md`); o
  conector não substitui esse registro.
- Quando a delegação depender de histórico ou continuidade entre sessões,
  usar a skill `cross-model-memory`. Ela exige escopo explícito no modelo de
  volume e uma sessão do modelo de julgamento restrita a ferramentas de
  leitura, fora do modo de planejamento.
- Sessões já abertas mantêm o snapshot de plugins do início. Instalação ou
  atualização passa a valer em uma nova sessão.

## Orçamento de delegação externa

- O modelo de volume recebe a maior parte do volume de dados, cobertura,
  pesquisa e comparação. Devolve síntese curta, contagens, lacunas e
  referências. Nunca despejar corpus bruto no contexto do condutor.
- Antes de chamar outro modelo, definir uma pergunta principal, allowlist de
  arquivos ou fontes, saída esperada, máximo de 800 palavras, evidência
  mínima e condição de parada.
- O modelo de volume usa no máximo 4 turnos por padrão. Até 6 somente para
  pesquisa volumosa com universo e endpoint mensuráveis. Oito turnos deixam
  de ser padrão.
- Dois turnos consecutivos sem nova fonte, achado, contagem ou redução
  objetiva da lacuna encerram o trabalho como inconclusivo.
- Segunda chamada na mesma subtarefa só após falha verificável. Deve reduzir
  pelo menos metade do escopo ou pedir uma evidência ausente específica.
  Nunca repetir prompt amplo.
- O modelo de julgamento usa uma chamada por decisão, máximo de 800
  palavras. Nova chamada somente por falha de runtime ou lacuna objetiva
  após confronto com a fonte.
- Resultado sem veredito, contraditório, interrompido ou encerrado pelo teto
  não vira conclusão. O condutor registra como incompleto e segue por
  evidência local.
- Quando o runtime informar uso, registrar turnos, tokens, duração e
  desfecho. Não ativar telemetria externa nem expor prompt para obter essas
  métricas.
- Busca local curta, comando de busca em arquivos, teste ou leitura de
  poucos arquivos fica no condutor quando tiver custo total menor. Delegar
  só para deslocar tokens, sem reduzir custo total, é proibido.
- Revisão independente pequena só vai ao modelo de volume quando pedida. O
  condutor prepara diff ou contexto de até 20.000 caracteres e exige
  resposta em uma única rodada, sem descoberta do workspace.
- No Windows, chamada textual ao modelo de volume pelo condutor exige
  terminal PTY (`tty: true`). Saída vazia sem PTY é falha de runtime, não
  parecer negativo. Remover códigos ANSI antes de interpretar o JSON de
  resposta.
- O modelo de volume possui contexto fixo relevante por chamada. Evitar
  microchamadas. Agrupar volume independente em um corpus delimitado e usar
  somente ferramentas liberadas para a tarefa.
- Delegação textual ao modelo de volume roda em um perfil isolado, fora de
  controle de versão, com login referenciado e sem acesso direto ao
  repositório. Enviar pacote embutido ou corpus sanitizado copiado para o
  diretório isolado.

### Variance: execução direta em terminal dedicado

- Status: aceita. Substitui parcialmente a regra de que o modelo de volume
  não altera a fonte principal.
- Delegação textual iniciada pelo condutor via conector local continua
  somente leitura.
- Um terminal próprio pode usar a CLI oficial do modelo de volume, em
  esforço alto (esforço máximo só em tarefa complexa), para editar somente
  arquivos atribuídos na tarefa daquele terminal.
- Essa autorização local não inclui commit, push, deploy, credenciais, ação
  destrutiva, envio ou qualquer efeito externo.
- O condutor segue como condutor quando invocado, integra resultados e
  executa verificação final. Continuidade entre sessões do modelo de volume
  exige handoff explícito via o servidor de memória compartilhada.

## Delegação econômica

- Não existe limite fixo de dois subagentes por tarefa. Use até três
  simultâneos, além do agente principal, e novas ondas quando houver mais
  trabalho independente.
- Paralelize somente tarefas independentes, delimitadas e verificáveis.
  Dependências ficam sequenciais.
- Não crie subagente para trabalho trivial, para repassar contexto
  continuamente ou apenas para parecer paralelo.
- Cada arquivo editável deve ter um único responsável durante trabalho
  paralelo.
- O condutor mantém o estado, confronta resultados, resolve divergências e
  executa a validação final.
- Para volume e cobertura, preferir o modelo de volume. Para construção e
  integração, o condutor. Para leitura rara do conjunto, o modelo de
  julgamento.
- Quando uma skill ou instrução específica do projeto exigir outro agente,
  respeitar essa exigência.
