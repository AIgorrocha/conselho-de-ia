# Aula 2.4: instalar e provar a memoria comum

Material de gravacao e execucao, revisao de 23/10/2026. Versao fixada: ai-memory
3.2.0. ai-memory e obrigatorio na arquitetura do curso. Este pacote prepara a
instalacao; os comandos de configuracao so sao executados pela escolha do aluno.

## O que o aluno precisa

- Windows x64 e PowerShell 5.1 ou posterior, acesso ao GitHub e espaco para
  binario e dados. Windows 11 ARM usa o executavel x64 por emulacao.
- Codex e Claude Code instalados/autenticados para a etapa de conectar agentes.
  O teste isolado de servidor nao precisa de assinatura ou chamada de modelo.
- Nao precisa de Ruby, Rust, Docker, PostgreSQL, GPU ou chave de API para o
  percurso nativo. Rust 1.95 so e necessario para compilar o projeto-fonte.
- Nao ha minimo oficial de CPU/RAM estabelecido nas fontes consultadas. Meça
  consumo no piloto; embeddings e LLM locais mudam o dimensionamento.

Windows nativo ainda e classificado como experimental na versao 3.2.0.
Politicas corporativas podem bloquear o executavel sem assinatura. Nao desative
protecao para contornar bloqueio; a equipe responsavel precisa avaliar o binario.

## Primeiro: plano sem instalar

Abra o PowerShell na raiz de uma copia deste kit:

```powershell
$destino = Join-Path $env:LOCALAPPDATA 'Programs\ai-memory-aula24'
powershell -NoProfile -File .\scripts\Preparar-Memoria.ps1 -Destino $destino
```

Saida esperada: plano da versao/destino, sem download nem mudanca. O destino
precisa ser novo. O launcher nao substitui sua instalacao anterior.

## Segundo: instalar somente o binario

Depois de revisar o plano, execute explicitamente:

```powershell
powershell -NoProfile -File .\scripts\Preparar-Memoria.ps1 -Destino $destino -Aplicar
$memoria = Join-Path $destino 'ai-memory.exe'
& $memoria --version
```

O launcher baixa o `install.ps1` oficial de v3.2.0 e seu checksum, compara ambos
com o SHA fixado e executa o instalador oficial em processo separado. O instalador
oficial baixa e verifica o ZIP da mesma versao. O launcher fixa destino e versao,
nao modifica PATH e nao executa setup, hooks, MCP, registro ou servico.
O arquivo verificado fica no diretorio temporario indicado na saida.

SHA-256 do instalador, baixado e verificado em 23/10/2026:
`86813bc1dc0e42e24d5ead57e56f3906c991fcd256f2642be959342945dce059`.
Checksum verifica consistencia do artefato; nao substitui confianca na origem.

## Terceiro: provar o servidor sem configurar seu perfil

```powershell
powershell -NoProfile -File .\scripts\Testar-Memoria.ps1 -Executavel $memoria
```

O teste cria uma pasta temporaria nova, seleciona porta de loopback livre e
inicia somente o executavel escolhido. O processo filho recebe ambiente minimo,
perfil/dados temporarios e configuracao explicita, sem herdar enderecos, tokens,
provedores ou configuracoes de memoria. Embeddings ficam desativados; nenhum
modelo e chamado. Nao instala servico, nao altera registro ou PATH e nao
registra MCP/hooks nos agentes.

O teste faz initialize, tools/list, grava as tres paginas publicas de
`wiki-modelo/`, busca, le a decisao e reinicia o servidor para conferir
persistencia. Encerra apenas o processo que iniciou. Preserva dados e log no
diretorio temporario informado para conferencia, sem apagar pastas existentes.

Saida esperada se passar:

```text
OK|checks=initialize,tools/list,importacao3,busca,leitura,reinicio|model_calls=0|global_changes=0
```

Prova realizada pelo autor em 23/10/2026, no Windows PowerShell 5.1: o launcher
com `-Aplicar` instalou o binario oficial 3.2.0 em um destino temporario novo.
Esse executavel baixado passou por initialize, tools/list, importacao sintetica,
busca, leitura e persistencia apos reinicio. Cinco configuracoes globais e o
PATH do usuario, comparados antes/depois, permaneceram inalterados. Nenhum setup,
servico, hook global ou chamada de modelo foi executado.

SHA-256 do executavel instalado pelo launcher:
`3e927bbbd19c71a575fb022dd32019ed7ade49d907885123147ba05c24e0002c`.
Essa prova cobre o download, a instalacao confinada e as operacoes sinteticas
do servidor. Nao comprova a instalacao no PC do aluno, captura dos agentes,
consumo de modelos ou funcionamento apos logoff/reboot.

## Quarto: configurar os agentes, apenas por escolha explicita

Esta etapa altera o perfil dos agentes e a inicializacao. Primeiro mostre o plano:

```powershell
$dados = Join-Path $env:LOCALAPPDATA 'ai-memory-aluno'
& $memoria setup --data-dir $dados --agent claude-code --agent codex --plan
```

Confira os caminhos, backups, agentes e politica de captura. Se o plano estiver
correto e voce quiser aplicar, execute interativamente e confirme a proposta:

```powershell
& $memoria setup --data-dir $dados --agent claude-code --agent codex
```

Nao usamos `--yes`. O setup oficial inicializa seus proprios dados e autenticacao
local, configura integracoes e inicio no logon. Nao cole sua credencial no chat,
em arquivo publico ou no Git. Reinicie os agentes e revise a confianca dos hooks
no cliente. No Codex, MCP conectado e hooks autorizados sao provas separadas.
Se ja houver instalacao, faca backup e revise conflitos antes de executar setup.

## Servidor, bridge e uso empresarial

`serve --transport http` executa o servidor. `mcp-bridge --no-session-id` e
um cliente stdio para um servidor HTTP existente, nao instala nem inicia esse
servidor. Os [exemplos MCP](../config/memoria-codex.toml.example) do kit dependem
do executavel e da configuracao privada corretos. Como o launcher deixa PATH
intacto, use o caminho absoluto de `ai-memory.exe` ao mesclar configuracao manual.
No modo estatico, passe workspace e project explicitamente nas consultas.

No PC pessoal, um servidor local pode atender seus agentes compativeis. Em uma
empresa, o responsavel pode manter uma base comum autorizada e conectar clientes
por configuracao individual. Nao distribua a credencial administrativa a equipe.
Configure identidades e acesso conforme a documentacao da versao instalada.

Projetos e namespaces organizam a busca; nao sao barreira de seguranca. A versao
3.2.0 nao oferece RBAC por pagina. Uma base empresarial compartilhada deve conter
somente dados que seus usuarios autorizados possam compartilhar; para separacao
confidencial, use instancias e acessos efetivamente separados.

Memoria nao e mensageria: `memory_query` busca, `memory_read_page` le a fonte e
`memory_message_send` so envia a outro projeto com autorizacao humana explicita.
Nao ha transferencia automatica de permissao, conversa completa ou execucao.

## O que mostrar na gravacao

1. Plano, versao, origem oficial e checksum; diferenciar preparar de aplicar.
2. Teste isolado e sua linha OK, ou erro real se ocorrer. Nao simular sucesso.
3. Tres paginas sinteticas, links de ida e volta, busca e leitura da decisao.
4. Plano do setup. Aplicacao no computador de demonstracao somente se desejada.
5. Nos dois agentes reiniciados, `memory_status` e consulta/leitura no mesmo escopo
   autorizado. Mostrar captura por hooks separadamente, quando configurada.

Nunca distribuir nossa memoria privada, backup, transcricoes, configuracao real,
enderecos internos ou credenciais. As paginas de estudo sao a base demonstrativa.

## Fontes e licenca

O launcher chama o instalador original sem inclui-lo neste repositorio. O projeto
original usa [MIT, Copyright 2026 Fabio Akita](https://github.com/akitaonrails/ai-memory/blob/v3.2.0/LICENSE).
Se redistribuir copia substancial do original, preserve a licenca e o aviso.

- [Instalador oficial v3.2.0](https://github.com/akitaonrails/ai-memory/releases/download/v3.2.0/install.ps1)
- [Checksum oficial](https://github.com/akitaonrails/ai-memory/releases/download/v3.2.0/install.ps1.sha256)
- [Windows v3.2.0](https://github.com/akitaonrails/ai-memory/blob/v3.2.0/docs/windows.md)
- [Instalacao v3.2.0](https://github.com/akitaonrails/ai-memory/blob/v3.2.0/docs/install.md)
- [Usuarios v3.2.0](https://github.com/akitaonrails/ai-memory/blob/v3.2.0/docs/users.md)

Versao fixada para reprodutibilidade. Atualizar exige nova verificacao e backup,
nao troca automatica por latest. Nenhum script desta aula publica ou faz commit.
