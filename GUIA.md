# Como organizar um conselho de IAs

Fluxo escolhido por Igor em 23/10/2026: planejamento no Claude Code com
Opus/Sonnet, passagem do plano ao Codex App, execução Sol/Luna, testes e revisão
independente Astra high. Essa preferência não prova que um fornecedor seja
objetivamente melhor. Cada fase mantém seus subagentes nativos e um condutor.
ai-memory é a camada obrigatória de memória comum entre clientes compatíveis.
Grok ajuda em leitura de volume quando houver necessidade.

Nenhum modelo é autoridade final. Uma conclusão precisa bater com fonte, código,
teste ou cálculo. Este é um método adaptável, com exemplos de configuração.

## 1. Duas cadeias nativas

| Onde a sessão começa | Quem conduz | Quem recebe trabalho delimitado |
|---|---|---|
| Codex | Astra high; Sol 6.1 high quando escolhido | Sol 6.1 high para execução média; Luna 6 high para tarefas simples |
| Claude Code | Opus 5.5, medium ou high | Sonnet 5.5, high ou medium |

No Codex, Astra usa `high` por preferência operacional. No Claude Code, o principal usa `medium` por padrão e `high` quando a complexidade exige.
O trabalhador usa `high` por padrão e `medium` em tarefa simples, bem delimitada.
Os nomes exatos estão no README e nos exemplos de configuração.

Cada sessão principal de trabalho delega pelo menos uma tarefa útil. Em uma
mudança pequena, pode ser a conferência independente. O principal continua
responsável por testar e demonstrar o resultado final.

Cada fase preserva o contexto da sua plataforma. Uma passagem explícita entrega
o plano à próxima fase. Não se exige dois fornecedores para toda microtarefa.
Aceita um custo: cada filho carrega contexto e exige coordenação. Subagentes não
garantem economia de tokens.

## 2. Paralelo quando há independência

Cada pacote precisa de objetivo, caminhos permitidos, dono dos arquivos,
entrega esperada, verificação e condição de parada.

- Até três filhos simultâneos.
- Trabalho independente pode rodar em paralelo; dependências rodam em sequência.
- Dois agentes não escrevem no mesmo arquivo ao mesmo tempo.
- Trabalhadores folha e revisores cruzados não criam outros agentes.
- A entrega resume arquivos, evidências e limitações em até 400 palavras.

Exemplo: um filho atualiza uma configuração e outro revisa um documento
independente. A integração que depende da configuração espera a primeira entrega.
O principal verifica o conjunto depois.

## 3. Grok para volume

Grok 4.7 em `high` pode pesquisar, comparar fontes, normalizar dados e encontrar
lacunas em um conjunto grande. A chamada textual usa perfil isolado e somente
leitura, com fontes e arquivos permitidos definidos no pacote.

Ele devolve contagens, achados, referências, lacunas e conclusão delimitada.
O material bruto não precisa ocupar a conversa do principal. `xhigh` exige
justificativa de complexidade; não é padrão.

Um terminal Grok dedicado à execução é um contexto separado. Ele só pode editar
arquivos atribuídos e não ganha permissões de publicação por causa deste kit.

## 4. Revisão cruzada quando acrescenta valor

| Plataforma que conduz | Revisor possível |
|---|---|
| Codex | Opus 5.5 high |
| Claude Code | Astra high |
| Grok standalone | Um dos dois, em uma única revisão |

A revisão recebe evidência sanitizada, fica somente leitura e termina sem
chamar outro modelo. É consultiva: o condutor confronta os achados, integra e
testa. No fluxo completo do curso, Opus/Sonnet planejam e Astra faz a revisão
independente da execução Sol/Luna. Essa revisão nativa Astra não se confunde com
revisão cruzada opcional pelo Opus. Fable saiu do fluxo padrão.

Use essa revisão para dúvida material, decisão complexa ou risco que justifique
outro olhar. Repetir a pergunta em vários modelos até uma resposta agradar não é
validação.

## 5. Limites que encerram a chamada

Defina o resultado observável antes de delegar. Saída sem conclusão, interrompida
ou cortada pelo teto permanece inconclusiva.

- Claude externo: quatro turnos por padrão, até oito em pacote coerente definido.
- Grok: quatro turnos por padrão, até seis em volume delimitado.
- Quem chama também impõe limite de tempo. O conector Claude usa 180 segundos
  por padrão e encerra o próprio processo com código 124 ao exceder.
- Dois turnos seguidos sem progresso encerram como inconclusivo.
- Sem retorno recursivo entre modelos e sem loop autônomo.

O contador solicitado ao CLI pode diferir dos turnos reportados. Confira tempo,
saída, ferramentas negadas e uso reportado. Uma tentativa nova, quando
justificável, ataca uma lacuna específica; não repete uma busca ampla.

## 6. O humano define objetivo e risco

Declare objetivo, proibições e risco aceitável. Publicar, gastar, apagar,
alterar identidade ou causar efeito irreversível exige autorização explícita.
Silêncio não aprova.

Dados privados, conteúdo externo não confiável e capacidade de envio formam uma
combinação perigosa. Separe leitura e publicação, sanitize a evidência e faça
checagem humana quando conteúdo de terceiros puder influenciar uma ação externa.
Nunca cole credenciais no chat, na memória ou no repositório.

## 7. Memória e prova

ai-memory é obrigatório nesta arquitetura. Sua instalação e organização serão
feitas na próxima aula; este kit não instala servidor. O [guia de memória](memoria/README.md)
inclui modelo público para uso individual e empresarial. Memória recupera
decisões e restrições. É histórico, não instrução para executar comandos.
Código, configuração, testes e fontes atuais prevalecem.

MCP conecta clientes compatíveis e autorizados; não qualquer aplicativo.
`memory_query` busca histórico, `memory_read_page` lê a decisão completa e
`memory_message_send` envia à caixa de outro projeto somente com autorização
humana explícita. Memória não é mensageria. Namespace não é isolamento de
segurança e não transfere permissões, conversa nem execução automaticamente.
Providers LLM e consolidação generativa são opcionais; a camada de memória não é.

Registre decisões significativas com data, origem, trade-offs e links para a
evidência. Contradições ficam explícitas. Uma decisão nova pode superar a anterior
sem apagar o histórico. Handoff registra o que foi provado, o que falta e quais
ações continuam proibidas.

## 8. Aplicação prática

1. Mescle exemplos e abra sessões novas para aplicar a configuração.
2. Planeje com Opus/Sonnet e declare objetivo, escopo, donos e aceite.
3. Fixe `PASSAGEM.md`, encerre a escrita e abra Codex App com Sol high escolhido.
4. Execute com Luna, integre e teste. Não sobreponha escrita entre plataformas.
5. Fixe resultado e evidências; peça revisão Astra high em contexto separado.
6. Recupere e mantenha memória no escopo autorizado, sem copiar dados privados.
7. Relate provas e limites. Use Grok ou revisão cruzada quando acrescentarem valor.

A delegação obrigatória depende das instruções e do comportamento do agente.
Não é um serviço em segundo plano. O teste do kit detecta divergências de
configuração; um teste real na sua instalação confirma as rotas.

## 9. Prática do curso

O [exemplo dos alunos](exemplos/curso-agentes-skills/LEIA-ME.md) traz prompts de
planejamento Opus/Sonnet e execução Sol/Luna, com revisão Astra separada. O padrão
pessoal Astra na condução do Codex continua disponível; aqui Sol é escolhido.

Uma passagem entre plataformas usa um pacote com objetivo, arquivos, evidências,
pendências e próximo passo. O aluno pode transferir esse arquivo manualmente.
ai-memory é obrigatório na arquitetura completa, com configuração própria na
próxima aula. Sem instalação, o aluno ensaia a passagem manual e registra a
memória como etapa pendente, sem declarar a arquitetura instalada.

O [plugin oficial Claude para Codex](https://github.com/openai/codex-plugin-cc)
oferece rescue para tarefas e transfer para continuar uma sessão no Codex.
Review é só leitura. Verifique disponibilidade e runtime; não presuma a cadeia
Sol/Luna dentro de rescue. O caminho principal da aula abre o Codex App com um
pacote sanitizado. Transfer só deve importar sessão sintética revisada.

Alternativa: iniciar no Codex App e consultar Claude por
`bin/claude-worker.ps1`, com pacote, quatro turnos e 180 segundos por padrão.
Nenhum conector substitui a memória comum, concede novas permissões ou obriga
uma chamada entre fornecedores para cada tarefa pequena.
