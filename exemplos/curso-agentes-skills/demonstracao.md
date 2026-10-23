# Demonstração para a gravação

Roteiro e gabarito, sem execução real incluída. Não apresente este arquivo como
log de agente. O executor e o revisor devem trabalhar sem consultar o gabarito.

## Sequência em tela

1. Mostrar uma cópia isolada da pasta e os três tipos de arquivo: regras,
   cadastro do agente e procedimento da skill. Mostrar os dados sintéticos.
2. Mostrar os modelos selecionados e a versão local. Explicar que disponibilidade
   depende da conta e que arquivo não muda sessão aberta.
3. No Claude Code, executar o prompt Opus/Sonnet do LEIA-ME. Abrir a atividade
   nativa para mostrar o filho Sonnet, modelo/esforço e skill. Se falhar, registrar
   a falha. Não encenar uma resposta do condutor como se fosse subagente.
4. Conferir as fontes e o `resultado.md` produzido. Preparar `PASSAGEM.md`,
   encerrar escrita e copiar pacote para nova sessão, se demonstrar continuidade.
5. No Codex novo, demonstrar Sol high com Luna high usando o primeiro prompt.
   Se houver resultado da trilha anterior, usar outra cópia para não sobrescrevê-lo.
6. Fixar `resultado.md`. Executar o prompt separado de Astra high em novo contexto.
   Mostrar o parecer e a conferência do condutor. Não tratar a opinião como prova.
7. Comparar a saída com este gabarito e registrar diferenças reais. Revisão cruzada
   Opus é opcional, distinta da revisão nativa Astra; não é necessária à prática.

Cada filho tem oito turnos, cinco minutos e 400 palavras. O condutor acompanha
tempo e turnos, encerra após dois turnos sem progresso e registra inconclusivo
se faltar resultado. Filhos não chamam agentes. Apenas um condutor escreve.

## Gabarito de atendimento

| Caso | Assunto | Urgência | Informação faltante | Resultado esperado |
|---|---|---|---|---|
| Ana | Entrega | Não indicada pelos dados | Identificador do pedido; sem previsão registrada | Perguntar pedido, sem prometer data ou status |
| Bruno | Troca | Não indicada pelos dados | Identificador do pedido e produto | Pedir ambos, sem prometer elegibilidade ou prazo |
| Carla | Pergunta já respondida | Não indicada pelos dados | Nenhuma para a pergunta já respondida | Sem novo rascunho, pois não há pergunta pendente |

Rascunhos possíveis, não únicos:

- Ana: “Olá, Ana. Pode informar o identificador do pedido para verificarmos?
  Não há previsão de entrega registrada neste material.”
- Bruno: “Olá, Bruno. Pode informar o identificador do pedido e qual produto
  deseja trocar?”
- Carla: “Pergunta já respondida, sem nova pergunta registrada. Não é necessário
  outro rascunho.” Esta é uma anotação interna, não mensagem para enviar.

Fontes: `casos.md`, seções Ana, Bruno e Carla, e regras de `contexto.md`.
Formulação pode variar. O aceite depende dos fatos e das lacunas preservadas.

## Extensão opcional de vendas

Não executar na triagem principal. Se pedida separadamente: kit escritório tem
contato há quatro dias, sem evidência de interesse, preço ou motivo do silêncio;
retomada é sugestão em rascunho. Renovação pede sexta-feira, sem data de calendário
nem confirmação de retorno. Não afirmar envio nem inventar condição comercial.

## Evidência a capturar durante a execução

- Versão, plataforma, modelo e esforço efetivos do principal e de cada filho.
- Atividade nativa e identidade do filho, arquivos lidos e aplicação da skill.
- Texto recebido, `resultado.md` fixado e parecer Astra em `revisao.md`.
- Conferência por caso e fonte; erros, correções propostas e itens inconclusivos.
- Tempo, turnos e consumo exibido, quando disponível. Não estimar economia.
- Passagem preenchida, origem sem escrita ativa e nova sessão no destino.

Não filme tokens, contas pessoais ou arquivos fora da cópia sintética. Configs,
captura de tela estática e este gabarito não comprovam chamada de modelo real.

## Opcional: mostrar a integração do kit

Mostre no LEIA-ME a diferença entre subagente nativo, conector externo e memória.
O conector `../../bin/claude-worker.ps1` do kit permite revisão Opus high,
somente leitura, com `PASSAGEM.md` sanitizado, quatro turnos e 180 segundos.
Só execute após pedido explícito e com o pacote de revisão preenchido. Sem
execução, mostre como exemplo de comando, nunca como parecer recebido.

Se houver ai-memory previamente autorizado, demonstre `memory_query` para
recuperar histórico e `memory_read_page` para ler a decisão completa, no escopo
correto. `memory_message_send` é envio explícito a outro projeto e exige
autorização humana específica; esta aula não precisa enviá-lo. Memória não é
mensageria e namespace não é isolamento. Não há servidor ou MCP instalado aqui.
