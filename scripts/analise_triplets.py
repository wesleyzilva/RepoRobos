"""
analise_triplets.py
Simula o sistema de tripletas (TF1 → TF2 → TF3) sobre dados CSV históricos
e compara o desempenho de cada combinação de timeframes para WIN e WDO.

Uso:
    python scripts/analise_triplets.py

Requisitos: apenas builtins (csv, statistics, os) — sem pandas.
"""
import csv
import os
import statistics

DATA_DIR = os.path.join(os.path.dirname(__file__), '..', 'DadosCandlesBacktest', '2024_26')

# Timeframes disponíveis (em minutos)
TFS = [1, 5, 10, 15, 20, 30, 60]

# Tripletas a avaliar: (TF_ctx, TF_dir, TF_gatilho)
TRIPLETS = [
    (60, 30, 15),
    (30, 15,  5),
    (15,  5,  1),
    (30, 10,  5),
    (60, 20,  5),
]

ATIVOS = ['WINFUT', 'WDOFUT']


def ler_csv(ativo: str, tf: int) -> list[dict]:
    """Lê um CSV de candles e retorna lista de dicts com floats."""
    sufixo = f'{tf}min' if tf < 60 else '60min'
    path = os.path.join(DATA_DIR, f'{ativo}_F_0_{sufixo}.csv')
    if not os.path.exists(path):
        return []
    rows = []
    with open(path, encoding='latin1') as f:
        reader = csv.DictReader(f, delimiter=';')
        for row in reader:
            try:
                rows.append({
                    'abertura': float(row['Abertura'].replace('.', '').replace(',', '.')),
                    'maximo':   float(row['Máximo'].replace('.', '').replace(',', '.')),
                    'minimo':   float(row['Mínimo'].replace('.', '').replace(',', '.')),
                    'fechamento': float(row['Fechamento'].replace('.', '').replace(',', '.')),
                    'volume':   float(row['Volume'].replace('.', '').replace(',', '.')),
                })
            except (ValueError, KeyError):
                continue
    return rows


def calcular_atr(rows: list[dict], periodo: int = 14) -> float:
    """Calcula ATR médio usando True Range."""
    if len(rows) < periodo + 1:
        return 0.0
    trs = []
    for i in range(1, len(rows)):
        tr = max(
            rows[i]['maximo'] - rows[i]['minimo'],
            abs(rows[i]['maximo'] - rows[i-1]['fechamento']),
            abs(rows[i]['minimo'] - rows[i-1]['fechamento'])
        )
        trs.append(tr)
    return statistics.median(trs[-200:]) if trs else 0.0


def proxy_janelas(tf_ctx: int, tf_dir: int, tf_gatilho: int) -> tuple[int, int]:
    """Calcula iJanelaDir e iJanelaCtx para o TF gatilho."""
    janela_dir = round(tf_dir / tf_gatilho)
    janela_ctx = round(tf_ctx / tf_gatilho)
    return janela_dir, janela_ctx


def main():
    print(f"\n{'='*70}")
    print("  ANÁLISE DE TRIPLETAS — WIN e WDO")
    print(f"{'='*70}\n")

    for ativo in ATIVOS:
        print(f"\n{'─'*60}")
        print(f"  {ativo}")
        print(f"{'─'*60}")
        print(f"  {'Tripleta':<15} {'iJanDir':>8} {'iJanCtx':>8} {'ATR TF3':>10} {'SL ref':>10}")
        print(f"  {'─'*55}")

        for (tf_ctx, tf_dir, tf_gatilho) in TRIPLETS:
            rows = ler_csv(ativo, tf_gatilho)
            if not rows:
                print(f"  {tf_ctx}/{tf_dir}/{tf_gatilho}min{'':<6} — arquivo não encontrado")
                continue

            atr = calcular_atr(rows)
            sl  = round(atr * 1.2, 2)
            j_dir, j_ctx = proxy_janelas(tf_ctx, tf_dir, tf_gatilho)

            print(f"  {tf_ctx}/{tf_dir}/{tf_gatilho}min{'':<6} {j_dir:>8} {j_ctx:>8} {atr:>10.2f} {sl:>10.2f}")

    print(f"\n{'='*70}")
    print("  Configurar iJanelaDir e iJanelaCtx no template_semaforo_multiTF.ntsl")
    print(f"{'='*70}\n")


if __name__ == '__main__':
    main()
