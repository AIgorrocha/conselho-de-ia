# Como organizar um conselho de IAs

O trabalho começa no Codex ou no Claude Code e continua nessa plataforma.
O agente principal entende o objetivo, distribui partes úteis, integra as
entregas e verifica o resultado. Subagentes nativos recebem pacotes delimitados.
Grok ajuda quando existe muito material para ler. Uma revisão de outro fornecedor
entra quando acrescenta uma verificação independente.

Nenhum modelo é autoridade final. Uma conclusão precisa bater com fonte, código,
teste ou cálculo. Este é um método adaptável, com exemplos de configuração.

## 1. Duas cadeias nativas

| Onde a sessão começa | Quem conduz | Quem recebe trabalho delimitado |
|---|---|---|
| Codex | Sol 6.1, medium ou high | Luna 6, high ou medium |
| Claude Code | Opus 5.5, medium ou high | Sonnet 5.5, high ou medium |

O principal usa `medium` por padrão e `high` quando a complexidade exige.
O trabalhador usa `high` por padrão e `medium` em tarefa simples, bem delimitada.
Os nomes exatos estão no README e nos exemplos de configuração.

Cada sessão principal de trabalho delega pelo menos uma tarefa útil. Em uma
mudança pequena, pode ser a conferência independente. O principal continua
responsável por testar e demonstrar o resultado final.

Isso preserva o contexto da plataforma e reduz dependências externas rotineiras.
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
| Claude Code | Sol 6.1 high |
| Grok standalone | Um dos dois, em uma única revisão |

A revisão recebe evidência sanitizada, fica somente leitura e termina sem
chamar outro modelo. É consultiva: o condutor confronta os achados, integra e
testa. Não existe planejador externo nem passada final obrigatória. Fable saiu
do fluxo padrão.

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

Memória compartilhada recupera decisões e restrições. É histórico, não instrução
para executar comandos. Código, configuração, testes e fontes atuais prevalecem.

Registre decisões significativas com data, origem, trade-offs e links para a
evidência. Contradições ficam explícitas. Uma decisão nova pode superar a anterior
sem apagar o histórico. Handoff registra o que foi provado, o que falta e quais
ações continuam proibidas.

## 8. Aplicação prática

1. Mescle os exemplos do README nas ferramentas instaladas.
2. Abra sessão nova para aplicar modelo e esforço configurados.
3. Declare objetivo e critérios de aceitação.
4. Delegue pacote útil, sem sobrepor escrita.
5. Integre e rode verificações locais.
6. Use Grok ou revisão cruzada quando a tarefa justificar.
7. Registre resultado e limitações, sem declarar concluído o que não foi provado.

A delegação obrigatória depende das instruções e do comportamento do agente.
Não é um serviço em segundo plano. O teste do kit detecta divergências de
configuração; um teste real na sua instalação confirma as rotas.
