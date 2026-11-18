"""Gera sql/02_dados.sql com dados fictícios e reproduzíveis (semente fixa)."""
import random
random.seed(42)

filiais = [(1, "Filial Centro", "Cidade A"), (2, "Filial Norte", "Cidade B"), (3, "Filial Sul", "Cidade C")]
nomes_v = ["Ana", "Bruno", "Carla", "Diego", "Elisa", "Fabio", "Gisele", "Hugo"]
vendedores = [(i + 1, f"Vendedor {n}", (i % 3) + 1) for i, n in enumerate(nomes_v)]
clientes = [(i, f"Cliente {i:03d}", random.choice(["Cidade A", "Cidade B", "Cidade C"])) for i in range(1, 61)]
modelos = [("Hatch 1.0", "novo", 72000), ("Sedan 1.6", "novo", 98000), ("SUV 2.0", "novo", 145000),
           ("Hatch 1.0 (usado)", "seminovo", 41000), ("Sedan 1.6 (usado)", "seminovo", 58000),
           ("Picape 2.8", "novo", 210000)]
veiculos = [(i + 1, m, c, p) for i, (m, c, p) in enumerate(modelos)]

linhas = []
q = lambda s: "'" + str(s).replace("'", "''") + "'"
def ins(t, rows):
    for r in rows:
        linhas.append(f"INSERT INTO {t} VALUES (" + ", ".join(q(x) if isinstance(x, str) else str(x) for x in r) + ");")

ins("filiais", filiais); ins("vendedores", vendedores); ins("clientes", clientes); ins("veiculos", veiculos)

vendas = []
for i in range(1, 181):
    mes = random.randint(1, 12)
    dia = random.randint(1, 28)
    v = random.choice(veiculos)
    desc = random.uniform(0.92, 1.0)
    vendas.append((i, f"2025-{mes:02d}-{dia:02d}", random.choice(clientes)[0], v[0],
                   random.choice(vendedores)[0], round(v[3] * desc, 2),
                   random.choice(["avista", "financiado", "financiado", "consorcio"])))
ins("vendas", sorted(vendas, key=lambda x: x[1]))

oss, itens, iid = [], [], 1
for i in range(1, 241):
    mes, dia = random.randint(1, 12), random.randint(1, 25)
    aberta = f"2025-{mes:02d}-{dia:02d}"
    fechada = None if (mes >= 10 and random.random() < 0.4) else f"2025-{mes:02d}-{dia + random.randint(0, 3):02d}"
    oss.append((i, aberta, fechada, random.choice(clientes)[0], random.choice(filiais)[0],
                random.choice(["revisao", "revisao", "mecanica", "funilaria"])))
    for _ in range(random.randint(1, 4)):
        itens.append((iid, i, random.choice(["Mão de obra", "Peça", "Filtro", "Pastilha", "Pintura"]),
                      round(random.uniform(60, 1800), 2))); iid += 1
for r in oss:
    linhas.append("INSERT INTO ordens_servico VALUES (" + ", ".join(
        "NULL" if x is None else (q(x) if isinstance(x, str) else str(x)) for x in r) + ");")
ins("os_itens", itens)

open("sql/02_dados.sql", "w", encoding="utf-8").write("\n".join(linhas) + "\n")
print(len(linhas), "linhas geradas")
