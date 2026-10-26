# Memória comum: acervo histórico de 23/10/2026

Encaminhamento atualizado em **26/10/2026**. O Conselho de IA trata da
orquestração. A instalação e o material atual da Aula 2.4 de AI Memory estão no
[pacote separado AI Memory Integração](https://github.com/AIgorrocha/ai-memory-integracao).
Esse pacote contém nossa camada de integração do
[projeto original de Fabio Akita](https://github.com/akitaonrails/ai-memory),
não um fork do servidor.

Os arquivos deste diretório permanecem como histórico da revisão de 23/10/2026.
O texto abaixo preserva o plano daquela data; referências a próxima aula e
comandos devem ser lidas nesse contexto. Para a prática atual, use o pacote
separado. ai-memory continua sendo dependência obrigatória da arquitetura.

## Material preservado de 23/10/2026

Revisão v2026.10.23, de 23/10/2026. ai-memory é obrigatório na arquitetura
ensinada. A próxima aula monta o servidor, conecta clientes compatíveis e
organiza a memória para uso individual e empresarial. Este diretório é material
público para copiar e importar, não instalação nem evidência de runtime.

O [guia da Aula 2.4](aula-2-4.md) traz os comandos, a versão fixada e a prova
isolada realizada no Windows. O [preparador](../scripts/Preparar-Memoria.ps1)
mostra o plano por padrão. O [teste](../scripts/Testar-Memoria.ps1) usa dados
temporários e não configura os agentes existentes.

## O que cada camada faz

| Camada | Responsabilidade |
|---|---|
| Regras e skills do projeto | Como trabalhar e quais limites respeitar |
| ai-memory compartilhado | Recuperar decisões, procedimentos e histórico com fontes |
| PASSAGEM.md | Entregar plano, versão fixada, provas e próximo passo à nova sessão |
| Código, testes e banco operacional | Comprovar comportamento e estado técnico atual |
| MCP | Conectar cliente compatível e autorizado às ferramentas do servidor |

MCP significa Model Context Protocol, protocolo de contexto e ferramentas.
Uma conexão não torna qualquer aplicativo compatível nem comprova captura.
Instalar plugin Claude/Codex não instala memória. Compartilhar memória não
transfere conversa completa, permissões de escrita, identidade ou execução.
Providers LLM e consolidação generativa são opcionais; a camada comum é obrigatória.

Há exemplos sem endpoint/token em
[configuração Codex](../config/memoria-codex.toml.example) e
[configuração Claude](../config/memoria-claude.json.example). Eles usam
`ai-memory mcp-bridge --no-session-id` e dependem do executável e da configuração
privada local de cada aluno apontando ao mesmo servidor autorizado. Não foram
instalados pelo kit. Em MCP estático, informe workspace e project explicitamente.
Captura e hooks são configurados e validados separadamente na próxima aula.

## Organização individual e empresarial

No uso individual, mantenha decisões pessoais e projetos em escopos explícitos.
No empresarial, defina responsável, fontes autorizadas, retenção, backup e quem
pode acessar a instância. Não misture dados privados de clientes na memória comum.

Namespace organiza busca, não é barreira de segurança. No uso individual ou em
equipe, configure e verifique identidades, permissões e escopos conforme a versão
e o acesso pretendido. Confira a [documentação de usuários](https://github.com/akitaonrails/ai-memory/blob/main/docs/users.md)
antes de compartilhar a instância; um nome de projeto sozinho não prova isolamento.

Nunca inclua endpoint privado, token, senha ou transcrição de cliente neste kit.
O objetivo é memória comum às IAs compatíveis e autorizadas daquele contexto,
não acesso universal a todos os dados por todas as ferramentas.

## Modelo público para copiar

```text
wiki-modelo/
  inicio.md
  procedimento-triagem.md
  decisao-rascunhos.md
```

Abra [inicio.md](wiki-modelo/inicio.md). As três páginas são sintéticas e têm
links de ida e volta. Copie a pasta para seu projeto de estudo. Na próxima aula,
revise o conteúdo, escolha a instância e o escopo de destino e importe pelas
ferramentas autorizadas da versão instalada. O teste isolado da Aula 2.4 importa
essas três páginas somente na base temporária que ele próprio cria.

Antes de importar, confira que cada link resolve. Ao gravar uma página no
servidor, preserve referência à fonte e o link de volta na página relacionada.
Grave só conteúdo durável sanitizado; não copie toda a conversa por conveniência.
Mudança de decisão registra nova data, origem e qual posição foi superada.

## Ferramentas e prova da próxima aula

1. Identificar versão, instância, credenciais fora de Git e escopo autorizado.
2. Testar `memory_status` e as ferramentas visíveis em cada cliente compatível.
3. Importar as três páginas sintéticas por escrita autorizada e conferir os links.
4. Usar `memory_query` para localizar a regra e `memory_read_page` para ler a
   página completa. Repetir de outro cliente autorizado no mesmo escopo e comparar
   conteúdo/fonte. Uma consulta bem-sucedida não comprova captura automática.
5. Separar conexão MCP, captura por hooks, busca e consolidação. Validar cada
   função configurada; hooks exigem suporte e confiança próprios do cliente.
6. Testar backup e recuperação antes de dados reais. Registrar falhas e lacunas.

`memory_message_send` é outra função: envia à caixa de outro projeto somente
com autorização humana explícita para esse envio. Memória não é mensageria.
A aula básica não precisa enviar mensagem. Silêncio nunca autoriza envio.

## Fontes e atualização

Projeto original de código aberto: [akitaonrails/ai-memory](https://github.com/akitaonrails/ai-memory).
Consulte a documentação da versão escolhida antes de instalar:

- [Instalação](https://github.com/akitaonrails/ai-memory/blob/main/docs/install.md)
- [Conexão MCP por cliente](https://github.com/akitaonrails/ai-memory/blob/main/docs/mcp-install.md)
- [Usuários e limites de acesso](https://github.com/akitaonrails/ai-memory/blob/main/docs/users.md)

Fontes consultadas em 23/10/2026. Registre versão/tag/commit utilizado na aula e
suas evidências. A base documental do kit é `6ffd360`; o commit de entrega desta
revisão deve ser conferido no Git. Não há sincronização automática prometida
entre modelo público, servidor instalado e configurações de cada aluno.
