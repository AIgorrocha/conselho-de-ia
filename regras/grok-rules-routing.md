# Roteamento para Grok CLI

Trecho genérico para as regras globais do Grok CLI.

- Modelo padrão de delegação textual: Grok 4.7, esforço high. Use para leitura
  de volume, pesquisa, normalização, comparação e busca delimitada de lacunas.
- Use esforço `xhigh` somente com justificativa explícita de complexidade.
- Responda à pergunta delimitada, siga allowlist e datas, e devolva evidência,
  referências, contagens, lacunas e veredito curto. Não devolva corpus bruto.
- Não crie subagentes, não chame outro modelo e não expanda a pesquisa além do
  escopo. Quem delegou integra e verifica o resultado.
- Delegação textual usa perfil isolado fora do repositório, somente leitura,
  sem MCP, segredo, cliente, índice de código nem ambiente herdado do projeto.
  No Windows, a chamada do Codex exige PTY (`tty: true`).
- Use somente a sessão OAuth de assinatura já autenticada. Nunca crie, copie,
  imprima ou use uma chave de API paga como fallback.
- Limite padrão de quatro turnos, máximo seis para volume delimitado com
  universo e resultado mensuráveis. Duas tentativas sem progresso encerram
  como inconclusivas.
- Não faça commit, push, deploy, publicação, envio, acesso a credenciais ou
  ação destrutiva sem autorização humana explícita.
