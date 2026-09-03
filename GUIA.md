# Como configurar um conselho de IAs para o seu trabalho

Isto é uma configuração genérica. Sirva-se dela para o seu próprio trabalho, com os
modelos de IA que você já usa. Não é o arquivo pessoal de ninguém, é o método.

A ideia central: em vez de conversar com uma IA só e aceitar a primeira resposta,
você monta um pequeno conselho. Um modelo conduz, outro faz o volume do trabalho
por um custo menor, um terceiro entra raramente para julgar o que ficou pronto, e
você sempre dá a palavra final. Cada papel existe por um motivo específico, não por
capricho, e é isso que este documento explica.

Nos exemplos abaixo usamos os nomes de três modelos conhecidos hoje (Codex, Grok e
Claude) só como referência de como cada papel costuma ser preenchido. Troque pelos
modelos que você usa. O que importa é a função de cada um, não a marca.

---

## 1. Três papéis, três motivos

Não existe um "melhor modelo" único. Existe o modelo certo para cada função, e o
critério é sempre o mesmo: quanto custa rodar aquilo, e o que essa tarefa exige.

**O condutor.** É o modelo que recebe a sua ideia, decide quem mais precisa entrar,
e no final confronta o resultado com a realidade (o código, os dados, os arquivos
de verdade) antes de aceitar como pronto. Ele é o condutor porque faz essa
conferência final, não porque é o mais "inteligente" dos três.

**Por quê:** sem alguém fechando o ciclo e checando contra a fonte real, cada
modelo entrega a própria versão da verdade e ninguém audita. O condutor é quem
garante que o que saiu bate com o que existe de fato.

**O modelo de volume.** É o que você aciona para pesquisa, comparação, tarefas
repetitivas e qualquer trabalho onde a quantidade importa mais que a profundidade
de julgamento.

**Por quê:** ele custa menos por chamada. Gastar o modelo caro em tarefa de volume
é queimar orçamento à toa. O barato faz o grosso do trabalho, e é revisado depois.

**O modelo de julgamento.** É o que entra raramente, só quando a decisão exige
leitura crítica, interpretação de contexto ou um julgamento difícil que os outros
dois não resolvem bem sozinhos.

**Por quê:** ele custa mais por chamada, então usar para volume seria desperdício.
A economia está em reservá-lo para o que só ele resolve bem: o julgamento fino, não
a repetição.

---

## 2. O seu papel: você é quem decide, sempre

Nenhum modelo é a autoridade final. Isso vale mesmo quando a resposta parece
completa e convincente.

**A regra:** você define o objetivo, o risco aceitável e o que está proibido antes
de qualquer modelo começar a trabalhar. E qualquer ação que não pode ser desfeita
(publicar algo publicamente, gastar dinheiro, enviar uma mensagem, mudar algo que
afeta outras pessoas) só acontece depois do seu "sim" explícito.

**Por quê:** modelos de IA não têm como saber sozinhos o que é reversível na sua
vida ou no seu negócio. Só você sabe o que realmente não pode dar errado. Por isso
a decisão de arriscar é sempre sua, nunca do modelo.

**Regra dura dentro dessa regra:** silêncio não é aprovação. Se você não respondeu,
a ação não acontece. Isso evita o cenário em que uma IA interpreta a sua falta de
resposta como um "pode seguir".

---

## 3. O limite de chamadas: por que isso não vira um looping infinito

Esta é a parte que diferencia um conselho de IAs organizado de simplesmente jogar a
mesma pergunta em três modelos até um deles "acertar por sorte".

**A regra:** cada tarefa pequena recebe no máximo uma chamada a um modelo externo
ao condutor. Uma segunda chamada só é permitida se a primeira falhou de um jeito
que dá para provar (um erro real, uma informação que faltou, um teste que não
passou), e mesmo assim ela tem que atacar exatamente o que faltou, nunca repetir a
mesma pergunta ampla esperando um resultado diferente.

**Por quê:** sem esse limite, é fácil cair num vaivém sem fim entre modelos, cada
um "revisando" o outro indefinidamente, gastando tempo e custo sem nenhuma garantia
de que a décima rodada é melhor que a segunda. O limite obriga cada chamada a valer
a pena e força quem conduz a decidir com o que já tem, em vez de terceirizar a
decisão para mais uma consulta.

**Como aplicar:** antes de acionar um modelo, escreva em uma frase o que você
espera de volta e quando vai considerar a resposta suficiente. Se a resposta não
vier com uma conclusão clara, ou for interrompida, ou ficar em cima do muro, ela
não conta como conclusão automaticamente. Trate como inconclusiva e decida com o
que você já tem, em vez de emendar outra chamada na esperança de uma resposta
melhor.

**O orçamento em números** (o padrão que este kit usa; ajuste ao seu contexto):

- O modelo de volume usa no máximo 4 turnos por chamada. Até 6 turnos, só quando a
  tarefa é uma pesquisa grande com um universo e um critério de conclusão bem
  definidos. Nunca 8 turnos como padrão.
- Dois turnos seguidos sem nenhuma evidência nova encerram a chamada como
  inconclusiva. Não insista tentando "mais uma vez".
- Cada chamada externa recebe um pedido autocontido: uma pergunta principal, a
  lista de arquivos ou fontes que ela pode olhar, o formato de resposta esperado,
  um teto de tamanho (por padrão, 800 palavras) e a condição que encerra a
  chamada.
- Nunca mandar o conteúdo bruto completo (um corpus inteiro, uma transcrição
  longa) para dentro da conversa do condutor. O modelo de volume processa o
  material grande e devolve só a síntese: contagens, achados, lacunas,
  referências.

---

## 4. O esforço de cada modelo: padrão e exceção

Cada modelo tem um nível de "esforço de raciocínio" configurável (em geral chamado
de `low`, `medium`, `high`, e em alguns provedores um nível extra acima de `high`).
Mais esforço custa mais e demora mais. A regra deste conselho é simples: todo mundo
começa no esforço padrão, e só sobe quando a tarefa realmente exige.

| Papel | Padrão | Só em tarefa complexa |
|---|---|---|
| Condutor | esforço alto | esforço máximo, só em tarefa complexa |
| Subagente do condutor | esforço alto | não sobe (esforço médio só para volume excepcional, quando o modelo de volume não está disponível) |
| Modelo de volume | esforço alto | esforço máximo, só em tarefa complexa |
| Modelo de julgamento | esforço alto | não sobe (esforço máximo proibido por padrão) |
| Subagentes abertos pelo modelo de julgamento | esforço alto | não sobe |

**Por que o padrão já é "alto" e não "médio":** um esforço baixo demais devolve
respostas rasas com mais frequência, e aí você paga de novo com uma segunda
chamada para corrigir. "Alto" costuma ser o ponto de equilíbrio. O que fica restrito
é o nível seguinte, o mais caro de todos, que só se justifica quando o custo de
errar é maior que o custo de gastar mais.

**Quando a tarefa é "complexa" o suficiente para subir de esforço.** Pelo menos UM
destes sinais precisa estar presente:

1. Mais de um sistema ou arquivo com dependência entre si.
2. Não existe um jeito verificável de conferir a resposta (nenhum teste, número ou
   fonte contra o qual comparar).
3. Um erro ali custa retrabalho grande, tem efeito para fora do seu computador, ou
   é uma decisão estrutural difícil de desfazer depois.
4. A tentativa no esforço padrão já falhou ou voltou sem uma conclusão clara.

Subir de esforço é sempre uma exceção declarada ("esforço máximo porque a tarefa
mexe em três sistemas ao mesmo tempo"), nunca um hábito silencioso.

**Quem chamar decide o custo total**, não só o esforço. Some: quanto da sua cota de
uso aquilo consome, quanto do seu tempo você vai gastar revisando, o retrabalho
esperado se sair errado, o risco de defeito e o atraso que isso causa. Escolha
sempre a combinação mais barata que ainda entrega um resultado aceitável.

Regra prática de quem entra em cada tipo de trabalho:

- Volume com um fim que dá para checar (pesquisa, comparação, cobertura, contagem)
  vai para o modelo de volume.
- Dúvida de julgamento (interpretar o conjunto, criticar de forma adversarial,
  copy, decisão conceitual) vai para o modelo de julgamento.
- Busca curta, teste rápido, leitura de poucos arquivos fica com o próprio
  condutor. Delegar isso para "economizar" quando na verdade só desloca tokens de
  um lugar para outro, sem baixar o custo total, é proibido.

E o mais importante: um resultado sem veredito claro, contraditório, ou que foi
cortado porque bateu no teto de turnos, não vira uma conclusão. Registre como
incompleto e siga com a evidência local que você já tem.

---

## 5. Como montar isso na prática

1. Escolha os três papéis (condutor, volume, julgamento) com os modelos que você já
   tem acesso hoje. Não precisam ser os mesmos três modelos do exemplo.
2. Escreva essas regras no arquivo de instruções da sua IA principal (o texto que
   ela lê antes de cada conversa), não como um lembrete solto no meio de uma
   conversa. Regra que não está escrita de forma permanente se perde na primeira
   sessão nova. Este kit já traz esse texto pronto em `regras/`.
3. Comece pedindo que o modelo de volume e o de julgamento trabalhem só em modo de
   leitura: eles pesquisam, comparam, analisam, mas não alteram nada direto. Só o
   condutor mexe na fonte principal do seu trabalho. Se mais tarde você abrir um
   terminal dedicado para o modelo de volume executar direto, ele edita só os
   arquivos atribuídos naquela tarefa, e continua sem commit, publicação ou
   qualquer efeito externo (exceção registrada em `regras/AGENTS.md`).
4. Defina para você mesmo o que conta como "ação irreversível" no seu
   contexto. Publicar um conteúdo, mandar uma mensagem, gastar dinheiro, apagar
   algo. Escreva essa lista, porque é ela que aciona a regra da seção 2.
5. Configure o esforço de cada papel conforme a tabela da seção 4, e escreva junto
   os quatro sinais de "tarefa complexa" que autorizam subir de esforço.
6. Revise depois de um tempo de uso: se você perceber que está sempre aprovando
   tudo sem examinar (virou um "sim" automático), pare e reveja se a regra do
   "sim" explícito ainda está sendo levada a sério.

Para a implementação técnica exata (arquivos de regra prontos para colar, trechos
de configuração, conectores de linha de comando e uma skill de coordenação entre
sessões), veja `README.md` neste mesmo kit.
