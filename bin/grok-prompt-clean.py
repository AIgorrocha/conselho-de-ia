# Filtro do hook UserPromptSubmit do Grok -> hook de memoria cross-sessao.
#
# O Grok CLI embrulha o prompt do usuario em <user_query>...</user_query>.
# Um MCP de memoria tipico usa a PRIMEIRA LINHA do prompt como titulo da
# pagina de sessao: sem este filtro, toda sessao do Grok fica com o titulo
# literal "<user_query>" (o texto completo ainda e salvo nas observacoes, mas
# titulo e lista de prompts da pagina sintetizada degradam).
#
# Este filtro le o payload JSON do stdin, desembrulha o campo "prompt" e
# repassa TUDO ao binario do hook de memoria com os mesmos argumentos.
# Fail-open: qualquer erro repassa o payload cru, a captura nunca para por
# causa do filtro.
#
# AI_MEMORY abaixo e um placeholder: aponte para o executavel do seu proprio
# hook de memoria (ai-memory ou qualquer MCP de memoria com hook compativel).
import json
import re
import subprocess
import sys

AI_MEMORY = r"%USERPROFILE%\bin\ai-memory.exe"
DIAG = r"%USERPROFILE%\bin\grok-prompt-clean.diag.txt"

raw = sys.stdin.buffer.read()
try:
    d = json.loads(raw.decode("utf-8", "replace"))
    p = d.get("prompt")
    if isinstance(p, str):
        m = re.search(r"<user_query>\s*(.*?)\s*</user_query>", p, re.DOTALL)
        if m:
            d["prompt"] = m.group(1)
            raw = json.dumps(d, ensure_ascii=False).encode("utf-8")
    else:
        # Formato inesperado: registra SO as chaves (nunca valores) pra diagnostico.
        with open(DIAG, "w", encoding="utf-8") as f:
            f.write("payload sem campo 'prompt' string; chaves: %s\n" % sorted(d.keys()))
except Exception:
    pass

proc = subprocess.run([AI_MEMORY, *sys.argv[1:]], input=raw)
sys.exit(proc.returncode)
