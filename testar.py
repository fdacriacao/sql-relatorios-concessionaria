"""Executa schema + dados + relatórios em um SQLite em memória e imprime o resultado.
Uso: python3 testar.py"""
import sqlite3, re

con = sqlite3.connect(":memory:")
con.execute("PRAGMA foreign_keys = ON")
for arq in ("sql/01_schema.sql", "sql/02_dados.sql"):
    con.executescript(open(arq, encoding="utf-8").read())

sql = open("sql/03_relatorios.sql", encoding="utf-8").read()
blocos = [b.strip() for b in re.split(r"(?m)^-- R\d+\.", sql)[1:] if b.strip()]
for i, b in enumerate(blocos, 1):
    titulo, _, consulta = b.partition("\n")
    cur = con.execute(consulta)
    cols = [d[0] for d in cur.description]
    rows = cur.fetchall()
    print(f"\n=== R{i}.{titulo} ({len(rows)} linhas) ===")
    print(" | ".join(cols))
    for r in rows[:5]:
        print(" | ".join(str(x) for x in r))
