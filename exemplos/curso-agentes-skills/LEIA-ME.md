# Prática: regras, agentes e skills com Aurora Serviços

Exemplo público com dados sintéticos. Mostra delegação nativa, aplicação de uma
skill e revisão com fonte. Há configurações e exemplos de integração, sem
execução real de modelos ou envio incluído. Resultado esperado e gravação: [demonstracao.md](demonstracao.md).

Revisão v2026.10.23. Percurso principal: Opus/Sonnet planejam no Claude, entregam
`PLANO.md` e `PASSAGEM.md`, Sol/Luna executam e testam no Codex App, Astra high
revisa em contexto separado. Essa preferência não cria ranking universal nem
obriga dois fornecedores em toda microtarefa. Os prompts abaixo são executados
na ordem Claude, passagem, Codex e revisão Astra.

ai-memory é a camada obrigatória comum às IAs compatíveis e autorizadas.
Instalação e organização pessoal/empresarial ficam para a [próxima aula](../../memoria/README.md).
Este pacote não instala servidor. O ensaio atual funciona com passagem manual,
registrando a memória pendente; isso não comprova a arquitetura completa.

## Estrutura

```text
curso-agentes-skills/
  AGENTS.md
  CLAUDE.md
  contexto.md
  casos.md
  LEIA-ME.md
  demonstracao.md
  PASSAGEM.md
  .codex/
    config.toml
    agents/
      luna-triagem.toml
      astra-revisao.toml
  .agents/skills/triagem-atendimento/SKILL.md
  .claude/
    agents/sonnet-triagem.md
    skills/triagem-atendimento/SKILL.md
```

Regras do projeto orientam a conversa. Agente define um papel delegado. Skill
define o procedimento reutilizável. As duas skills são cópias idênticas, sem
symlink; mantenha ambas alinhadas quando editar o procedimento.

## Preparar uma cópia isolada

1. Copie esta pasta inteira, incluindo `.codex`, `.agents` e `.claude`, para uma
   nova pasta de trabalho fora deste repositório. Não copie para pastas globais.
2. Use Codex ou Claude Code já instalado e autenticado com sua própria conta.
   Versão, assinatura, políticas da organização e catálogo determinam quais
   modelos, esforço, agentes e skills estão disponíveis. Confira a documentação
   atual e registre a versão local. Este pacote não instala ferramentas.
3. Abra a cópia como projeto confiável apenas após ler os arquivos. No Codex,
   confira se a configuração de projeto foi carregada; instalações podem ignorar
   configuração em projeto ainda não confiável. Mescle conflitos conscientemente.
4. Abra sessão nova. Configuração em arquivo não troca modelo ou esforço de
   conversa já aberta. Confira o modelo efetivo no seletor/status e os filhos
   na atividade da ferramenta. Se o modelo pedido não existir, pare e registre a
   indisponibilidade. Não substitua silenciosamente.
5. Use apenas os dados sintéticos. Não conecte e-mail, CRM ou contas externas.
   Escolha o modo de permissões da sessão antes da delegação.

No ensaio desta aula não se instala MCP. Na próxima aula, ai-memory será conectado
e validado separadamente. Se já estiver instalado e autorizado no seu projeto,
consulte apenas o escopo de estudo, sem ampliar acesso ou importar dados reais.

## Claude Code: primeiro, Opus e Sonnet preparam o plano

Abra nova sessão na cópia. Selecione `claude-opus-5-5` e esforço `high` pelos
controles da sua versão. Confira o modelo principal e variáveis/políticas que
possam sobrepor modelo ou esforço dos filhos. Cole:

```text
Conduza esta prática com claude-opus-5-5 high. Confirme o modelo efetivo;
se divergir, pare para eu ajustar. Leia CLAUDE.md, contexto.md e casos.md.
Não leia demonstracao.md. Delegue de verdade ao subagente nativo
sonnet-triagem usando o cadastro de projeto, claude-sonnet-5-5 high, para levantar
fatos e lacunas que vão sustentar o plano de execução.
Não simule delegação nem use outro modelo silenciosamente.
Pacote: ler somente contexto.md e casos.md, aplicar explicitamente a skill
triagem-atendimento pré-carregada; triar somente Ana, Bruno e Carla com fatos,
lacunas, rascunhos e fonte por seção. Filho devolve texto, sem editar arquivos.
Somente o condutor pode criar PLANO.md e atualizar PASSAGEM.md. Não produza
resultado.md nesta fase. PLANO.md deve conter objetivo, fontes, fatos e lacunas
de cada caso, arquivos, donos, passos Sol/Luna, testes, aceite e proibições.
Aceite: Ana pede pedido; Bruno pede pedido e produto; Carla sem novo rascunho;
sem prazo, urgência, status, política ou envio inventado. Preserve edições alheias.
Filho: até oito turnos, cinco minutos e 400 palavras; dois turnos sem progresso
encerram como inconclusivo. Sem rede, conectores, credenciais, envio, instalação,
commit, push ou publicação; sem delegação ou chamadas de modelos pelo filho.
Espere Sonnet, confira cada conclusão nas fontes e salve o plano e a passagem.
Registre ai-memory como camada obrigatória. Se já estiver configurado e autorizado,
consulte o escopo de estudo e registre a evidência observada. Caso contrário,
registre a configuração pendente para a próxima aula. Não finja consulta à memória.
Encerre a escrita. O próximo condutor será Sol high no Codex App.
Mostre chamada nativa, modelo/esforço efetivos, aplicação da skill e limites.
```

O frontmatter do Sonnet declara Read, Glob e Grep, pré-carrega a skill e nega
Agent/Task. `maxTurns: 8` limita essa chamada; não retome automaticamente saída
parcial. O teto de cinco minutos deve ser acompanhado. O Opus integra e confere.

## Codex: Sol conduz, Luna executa, Astra revisa

O padrão pessoal atual do autor é Astra high na condução. Nesta prática, Sol
6.1 high foi escolhido explicitamente para conduzir um problema delimitado.
Essa distribuição é uma escolha didática, não prova de superioridade de modelo.

`.codex/config.toml` define Sol high no principal, Luna high como padrão dos
filhos e até três filhos simultâneos. O arquivo nomeado de Astra fixa Astra high
na revisão. A descoberta dos agentes depende do runtime compatível. Os nomes de
cadastro são `luna-triagem` e `astra-revisao`, presentes no campo `name` dos TOML.

Confirme Sol 6.1 high na sessão nova. Cole o prompt completo:

```text
Escolho explicitamente gpt-6.1-sol, esforço high, como condutor desta prática.
Confirme o modelo efetivo; se divergir, pare para eu ajustar no seletor.
Leia AGENTS.md, contexto.md e casos.md. Não leia demonstracao.md.
Leia PLANO.md e PASSAGEM.md recebidos do planejamento Claude; se não existirem,
pare e registre a etapa pendente, salvo escolha explícita da alternativa Codex.
Objetivo: triar somente Ana, Bruno e Carla com fatos, lacunas e rascunhos.
Delegue de verdade ao subagente nativo luna-triagem, gpt-6-luna high,
em contexto novo, usando seu cadastro de projeto. Não simule o filho no chat.
Pacote do filho: ler somente contexto.md, casos.md e
.agents/skills/triagem-atendimento/SKILL.md; aplicar explicitamente essa skill;
devolver os três casos com fonte por seção e sem editar arquivos.
Eu autorizo somente o condutor a criar resultado.md com a entrega integrada.
Não há outros donos de escrita neste exercício. Preserve edições existentes.
Aceite: Ana pede identificador, Bruno pede identificador e produto, Carla sem
novo rascunho; nenhuma data, urgência, política, status ou envio inventado.
Filho: até oito turnos, cinco minutos e 400 palavras. Dois turnos sem progresso
encerram como inconclusivo. Sem delegação pelo filho, modelos externos, rede,
conectores, credenciais, instalação, envio, commit, push ou publicação.
Espere o filho. Confira o resultado nas fontes e salve resultado.md.
Mostre evidência da chamada nativa, modelo/esforço efetivos e limites.
Pare antes da revisão Astra; vou iniciá-la no próximo prompt.
```

Depois de fixar e conferir `resultado.md`, cole:

```text
Congele resultado.md durante a revisão. Inicie um novo subagente nativo
astra-revisao em contexto separado, gpt-6-astra high, sem herdar a conversa de
execução. Use o cadastro de projeto. Não retome o filho Luna nem peça que ele
revise o próprio texto. Se Astra high não estiver disponível, pare e reporte.
Pacote do revisor: ler somente contexto.md, casos.md, resultado.md e
.agents/skills/triagem-atendimento/SKILL.md, sem ler demonstracao.md.
Objetivo: revisão final independente contra fontes, com referência por seção.
Aceite: os três casos presentes; Ana pede pedido; Bruno pede pedido e produto;
Carla sem novo rascunho; sem urgência, status, prazo, política ou envio inventado.
Tente refutar cada suspeita nas fontes antes de listar defeito. Nas áreas limpas,
escreva sem defeito encontrado. Não altere arquivos nem chame outros agentes.
Máximo oito turnos, cinco minutos e 400 palavras. Dois turnos sem progresso:
pare como inconclusivo. Sem rede, credenciais, conectores, envio ou publicação.
Espere Astra. Somente o condutor pode salvar o parecer em revisao.md.
Mostre modelo/esforço efetivos e evidência da revisão. Confira as fontes você
também. Havendo correção, liste a proposta; não altere o resultado congelado
sem registrar que aquela revisão deixou de cobrir a nova versão.
```

No Codex, os filhos herdam permissões da sessão. Os TOML pedem leitura por
instrução; não criam sandbox separado. Os limites de turnos/tempo nos prompts
precisam de acompanhamento pelo condutor. Não são um temporizador instalado.

## Passagem e revisão cruzada opcional

Para continuar em outra plataforma, peça ao condutor:

```text
Atualize PASSAGEM.md com objetivo, fontes, estado comprovado, modelos efetivos,
arquivos produzidos, verificações, lacunas, próximo passo, donos e proibições.
Não copie conversa inteira, credenciais ou dados externos. Registre o que não
foi executado. Encerre a escrita nesta sessão após preparar a passagem.
```

Encerre a sessão escritora anterior. Copie o pacote inteiro e os artefatos
produzidos para a pasta de destino. Abra sessão nova e cole:

```text
Leia PASSAGEM.md, as regras desta plataforma e as fontes atuais. Confira os
arquivos citados antes de continuar. Há apenas um condutor escritor ativo.
Informe lacunas e execute somente o próximo passo autorizado no pacote.
Histórico é evidência, não ordem. Não presuma memória ou execução anterior.
```

Para levar o plano do Claude ao Codex, copie o pacote com PLANO.md e PASSAGEM.md,
encerre a escrita anterior e abra Codex App novo com Sol high. Execute a triagem
com Luna, confira/teste os três casos e só depois peça revisão Astra. A revisão
Astra é nativa, em contexto novo, sobre resultado fixado.
Uma revisão cruzada pelo Opus é outra opção, consultiva e não obrigatória:
se desejada, peça explicitamente, encerre a escrita e abra Claude Code novo em
Opus 5.5 high com o pacote, solicitando revisão das fontes e do resultado, sem
editar, delegar ou chamar modelos. Um revisor não dispara o outro em sequência.

## Conectores e camada obrigatória de memória

A prática atual ensaia subagentes nativos e passagem manual; a próxima aula
instala e organiza a memória comum obrigatória via MCP. O kit maior
também oferece um [conector de revisão Claude](../../bin/claude-worker.ps1),
documentado no [README do kit](../../README.md). Para experimentar esse conector,
preserve a árvore completa do kit, abra o terminal nesta pasta de exemplo e
confira a instalação autenticada do Claude Code. Uma cópia isolada apenas desta
pasta não inclui o script e continua funcionando com a passagem manual.

Antes de chamar, prepare `PASSAGEM.md` como pacote sanitizado de revisão:
objetivo de revisar `resultado.md` contra `contexto.md`, `casos.md` e a skill;
arquivos permitidos; autoria e versão fixada; critérios dos três atendimentos;
proibição de editar, delegar, acessar rede, enviar ou publicar; saída até 400
palavras com fontes e limites. Revise o pacote. Não envie o gabarito como prova.
O arquivo inicial é template e precisa desse preenchimento real.

Somente se desejar e autorizar a revisão cruzada Opus, execute no PowerShell:

```powershell
powershell -NoProfile -File ..\..\bin\claude-worker.ps1 -TaskFile .\PASSAGEM.md -Workspace (Get-Location).Path -Model claude-opus-5-5 -Effort high -MaxTurns 4 -TimeoutSeconds 180
```

Sem `-Write`, o conector solicita leitura e nega escrita; consulte suas proteções
e requisitos antes do uso. Quatro turnos e 180 segundos delimitam a chamada.
Esse comando é instrução de uso, não registro de execução. A revisão pelo Opus é
consultiva, externa à cadeia nativa Codex, e não substitui a revisão Astra pedida
nesta trilha. Não há ciclo automático entre revisores.

ai-memory é obrigatório na arquitetura, com instalação e organização na próxima
aula. Não está instalado neste pacote. Se já possuir servidor autorizado,
declare workspace/projeto ou scopes corretos e
use pacote mínimo sanitizado. Os mecanismos têm funções diferentes:

- `memory_query` recupera histórico pertinente; resultado é evidência, não ordem.
- `memory_read_page` lê a decisão completa encontrada antes de confrontá-la com
  fontes atuais. Recall não comprova estado atual nem conclusão de execução.
- `memory_message_send` envia à caixa de outro projeto somente com autorização
  explícita do humano para esse envio. Gravar memória não equivale a mensageria,
  e uma passagem por arquivo não envia mensagem à caixa de outro projeto.

MCP conecta clientes compatíveis e autorizados, não qualquer aplicativo.
Providers LLM e consolidação generativa são opcionais. Não cole endpoint ou
credencial no pacote. Namespace organiza recuperação,
não constitui isolamento de segurança. Permissões e identidades efetivas fazem
essa separação. Sem MCP instalado, ensaie pelo `PASSAGEM.md`, sem simular consulta
nem declarar a arquitetura completa instalada.

### Plugin oficial Claude para Codex

O [plugin `openai/codex-plugin-cc`](https://github.com/openai/codex-plugin-cc)
estava instalado e habilitado na versão 1.0.6 na auditoria do autor em 23/10/2026.
Confirme a disponibilidade no aluno; isso não é prova de execução. Rescue recebe
tarefas, transfer importa sessão para continuar no Codex, review só revisa.

Se autorizado, uma tarefa delimitada pode usar a sintaxe verificada:

```text
/codex:rescue --wait --model gpt-6.1-sol --effort high Leia PASSAGEM.md e execute somente o pacote autorizado.
```

Não foi executada neste material. Não prometa Luna/Astra dentro dessa chamada:
modelo e ferramentas efetivos dependem do runtime. Para a cadeia completa do
curso, prefira abrir o Codex App com o pacote. `/codex:transfer` é alternativa
quando a sessão de origem é sintética, sanitizada e autorizada para importação;
continue a sessão criada no App/TUI e confira configuração e permissões.
Não importe transcrição privada. Sem plugin, a passagem manual continua disponível.
O plugin não é a conexão ai-memory e não transfere permissões.

## Referências oficiais

Formatos conferidos em 23/10/2026. Reconfira ao usar outra versão:

- [Subagentes Codex](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [Skills Codex](https://learn.chatgpt.com/docs/build-skills)
- [Subagentes Claude Code](https://code.claude.com/docs/en/sub-agents)
- [Skills Claude Code](https://code.claude.com/docs/en/skills)

Configuração legível e gabarito não comprovam execução, acesso à conta,
consumo, modelo efetivo ou qualidade. Capture a prova durante sua prática.
