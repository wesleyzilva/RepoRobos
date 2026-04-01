"""
analisa_backtest_profit.py
==========================
Analisa CSV de operacoes exportado do backtest do Neologica Profit.
Calcula metricas completas e compara multiplos robos/TFs lado a lado.

Uso:
    # Um arquivo:
    python scripts/analisa_backtest_profit.py backtest_resultados/FORCA_SAIDA_OCO_60MIN.csv

    # Pasta inteira (compara todos):
    python scripts/analisa_backtest_profit.py backtest_resultados/

Requisitos: Python 3.8+  |  pip install pandas tabulate  (opcional mas recomendado)
"""

import csv
import os
import sys
from collections import defaultdict
from datetime import datetime

# ---------------------------------------------------------------------------
# CONFIGURACAO — ajuste se as colunas do seu export forem diferentes
# ---------------------------------------------------------------------------
COLUMN_MAP = {
    # chave interna : lista de possiveis nomes no CSV (case-insensitive)
    "entrada":    ["entrada", "data entrada", "data de entrada", "open time", "abertura"],
    "saida":      ["saida", "saída", "data saida", "data de saida", "close time", "fechamento"],
    "tipo":       ["tipo", "direcao", "direção", "direcao", "side", "operacao", "operação"],
    "quantidade": ["qtde", "quantidade", "qty", "contratos", "volume"],
    "preco_in":   ["preço entrada", "preco entrada", "preco_entrada", "entrada preco", "open price"],
    "preco_out":  ["preço saida", "preco saida", "preço saída", "preco_saida", "saida preco", "close price"],
    "resultado_pts": ["resultado (pts)", "resultado pts", "pts", "pontos", "resultado pontos"],
    "resultado_rs":  ["resultado (r$)", "resultado r$", "resultado", "financeiro", "p&l", "pl"],
}

# Custo por trade (spread + slippage) em R$ — ajuste conforme ativo
CUSTO_POR_TRADE_RS = 5.00   # WIN: 25pts * R$0.20/pt/contrato = R$5 por contrato
# Se quiser usar pontos, ajuste aqui e o script converte automaticamente

# ---------------------------------------------------------------------------
# HELPERS
# ---------------------------------------------------------------------------

def parse_br_number(s: str) -> float:
    """Converte '1.234,56' ou '1234,56' ou '1234.56' para float."""
    if s is None:
        return 0.0
    s = str(s).strip().replace(" ", "")
    if not s or s in ("-", ""):
        return 0.0
    # Remove sinal negativo para processar, restaura depois
    negativo = s.startswith("-")
    s = s.lstrip("-")
    # Formato BR: ponto = milhar, virgula = decimal
    if "," in s and "." in s:
        s = s.replace(".", "").replace(",", ".")
    elif "," in s:
        s = s.replace(",", ".")
    try:
        v = float(s)
        return -v if negativo else v
    except ValueError:
        return 0.0


def parse_datetime(s: str) -> datetime | None:
    """Tenta varios formatos de data/hora BR e ISO."""
    if not s:
        return None
    s = str(s).strip()
    formatos = [
        "%d/%m/%Y %H:%M:%S",
        "%d/%m/%Y %H:%M",
        "%d/%m/%Y",
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%d %H:%M",
        "%Y-%m-%d",
    ]
    for fmt in formatos:
        try:
            return datetime.strptime(s, fmt)
        except ValueError:
            continue
    return None


def detect_column(header_row: list[str], key: str) -> int | None:
    """Retorna o indice da coluna mapeada ou None."""
    candidates = COLUMN_MAP.get(key, [])
    for i, h in enumerate(header_row):
        h_clean = h.strip().lower()
        if h_clean in candidates:
            return i
    return None


def detect_encoding(filepath: str) -> str:
    """Tenta UTF-8 primeiro; se falhar, usa latin-1 (padrao Profit Windows)."""
    try:
        with open(filepath, encoding="utf-8") as f:
            f.read()
        return "utf-8"
    except UnicodeDecodeError:
        return "latin-1"


def detect_separator(filepath: str) -> str:
    """Detecta separador de coluna (ponto-e-virgula ou virgula)."""
    enc = "utf-8"
    try:
        with open(filepath, encoding="utf-8") as f:
            linha = f.readline()
    except UnicodeDecodeError:
        enc = "latin-1"
        with open(filepath, encoding="latin-1") as f:
            linha = f.readline()
    return ";" if linha.count(";") >= linha.count(",") else ","


def load_csv(filepath: str) -> list[dict]:
    """
    Le o CSV do Profit e retorna lista de dicts com campos normalizados.
    Cada dict: entrada, saida, tipo, quantidade, preco_in, preco_out,
               resultado_pts, resultado_rs
    """
    sep = detect_separator(filepath)
    enc = detect_encoding(filepath)
    operacoes = []

    with open(filepath, encoding=enc, newline="") as f:
        reader = csv.reader(f, delimiter=sep)
        header = None
        col_idx = {}

        for row in reader:
            # Pular linhas vazias
            if not any(c.strip() for c in row):
                continue

            # Detectar cabecalho
            if header is None:
                header = [c.strip().lower() for c in row]
                for key in COLUMN_MAP:
                    col_idx[key] = detect_column(header, key)
                # Verificar se temos pelo menos resultado
                if col_idx.get("resultado_rs") is None and col_idx.get("resultado_pts") is None:
                    print(f"\n[AVISO] Nao encontrei coluna de resultado em: {filepath}")
                    print(f"Colunas encontradas: {header}")
                    print("Ajuste o COLUMN_MAP no inicio do script.\n")
                    return []
                continue

            def get(key):
                idx = col_idx.get(key)
                return row[idx].strip() if idx is not None and idx < len(row) else ""

            # Resultado em R$ (preferencial) ou em pontos
            rs = parse_br_number(get("resultado_rs"))
            pts = parse_br_number(get("resultado_pts"))

            # Se so temos pontos, estimar R$ (WIN: 1pt = R$0.20, 3 contratos = R$0.60/pt)
            qtde_str = get("quantidade")
            qtde = int(parse_br_number(qtde_str)) if qtde_str else 1
            if rs == 0.0 and pts != 0.0:
                rs = pts * 0.20 * qtde  # estimativa WIN mini

            entrada_dt = parse_datetime(get("entrada"))
            saida_dt   = parse_datetime(get("saida"))

            tipo = get("tipo").lower()
            if not tipo:
                tipo = "compra" if rs >= 0 else "venda"

            operacoes.append({
                "entrada":      entrada_dt,
                "saida":        saida_dt,
                "tipo":         tipo,
                "quantidade":   qtde,
                "preco_in":     parse_br_number(get("preco_in")),
                "preco_out":    parse_br_number(get("preco_out")),
                "resultado_pts": pts,
                "resultado_rs":  rs,
            })

    return operacoes


# ---------------------------------------------------------------------------
# CALCULOS DE METRICAS
# ---------------------------------------------------------------------------

def calcular_metricas(ops: list[dict], nome: str = "", custo_por_trade: float = CUSTO_POR_TRADE_RS) -> dict:
    if not ops:
        return {"nome": nome, "erro": "Sem operacoes"}

    total = len(ops)
    resultados = [o["resultado_rs"] for o in ops]

    # Custo total (spread + slippage)
    custo_total = custo_por_trade * total
    resultados_liq = [r - custo_por_trade for r in resultados]

    wins  = [r for r in resultados_liq if r > 0]
    loses = [r for r in resultados_liq if r <= 0]

    n_wins  = len(wins)
    n_loses = len(loses)
    win_rate = n_wins / total * 100 if total > 0 else 0

    soma_ganhos = sum(wins)
    soma_perdas = abs(sum(loses))
    fator_lucro = soma_ganhos / soma_perdas if soma_perdas > 0 else float("inf")

    media_ganho = soma_ganhos / n_wins  if n_wins  > 0 else 0
    media_perda = soma_perdas / n_loses if n_loses > 0 else 0
    rrr_medio   = media_ganho / media_perda if media_perda > 0 else float("inf")

    resultado_bruto  = sum(resultados)
    resultado_liquido = sum(resultados_liq)
    esperanca = resultado_liquido / total if total > 0 else 0

    # Drawdown maximo (em R$)
    equity = 0
    peak = 0
    max_dd = 0
    for r in resultados_liq:
        equity += r
        if equity > peak:
            peak = equity
        dd = peak - equity
        if dd > max_dd:
            max_dd = dd

    # Sequencia maxima de perdas consecutivas
    max_seq_perda = seq_atual = 0
    for r in resultados_liq:
        if r <= 0:
            seq_atual += 1
            max_seq_perda = max(max_seq_perda, seq_atual)
        else:
            seq_atual = 0

    # Distribuicao por hora de entrada
    hora_dist = defaultdict(lambda: {"wins": 0, "loses": 0})
    for o, r in zip(ops, resultados_liq):
        if o["entrada"]:
            h = o["entrada"].hour
            if r > 0:
                hora_dist[h]["wins"] += 1
            else:
                hora_dist[h]["loses"] += 1

    # Melhor hora
    melhor_hora = max(hora_dist, key=lambda h: hora_dist[h]["wins"] - hora_dist[h]["loses"]) if hora_dist else None

    # Duracao media da operacao (minutos)
    duracoes = []
    for o in ops:
        if o["entrada"] and o["saida"]:
            dur = (o["saida"] - o["entrada"]).total_seconds() / 60
            duracoes.append(dur)
    duracao_media = sum(duracoes) / len(duracoes) if duracoes else 0

    return {
        "nome":             nome,
        "total_trades":     total,
        "wins":             n_wins,
        "loses":            n_loses,
        "win_rate":         win_rate,
        "soma_ganhos":      soma_ganhos,
        "soma_perdas":      -soma_perdas,
        "fator_lucro":      fator_lucro,
        "media_ganho":      media_ganho,
        "media_perda":      -media_perda,
        "rrr_medio":        rrr_medio,
        "resultado_bruto":  resultado_bruto,
        "custo_total":      custo_total,
        "resultado_liquido": resultado_liquido,
        "esperanca_trade":  esperanca,
        "max_drawdown":     -max_dd,
        "max_seq_perda":    max_seq_perda,
        "melhor_hora":      melhor_hora,
        "duracao_media_min": duracao_media,
        "amostra_ok":       total >= 50,
    }


# ---------------------------------------------------------------------------
# SAIDA FORMATADA
# ---------------------------------------------------------------------------

VERDE   = "\033[92m"
VERMELHO = "\033[91m"
AMARELO = "\033[93m"
RESET   = "\033[0m"
NEGRITO = "\033[1m"


def cor(valor, bom_se_positivo=True):
    if isinstance(valor, (int, float)):
        positivo = valor > 0
    else:
        positivo = bool(valor)
    c = VERDE if (positivo == bom_se_positivo) else VERMELHO
    return f"{c}{valor}{RESET}"


def fmt_rs(v):
    return f"R$ {v:+.2f}"


def fmt_pct(v):
    return f"{v:.1f}%"


def fmt_x(v):
    if v == float("inf"):
        return "inf"
    return f"{v:.2f}x"


def imprimir_relatorio(m: dict):
    print()
    print(f"{NEGRITO}{'='*60}{RESET}")
    print(f"{NEGRITO}  {m['nome']}{RESET}")
    print(f"{'='*60}")

    if "erro" in m:
        print(f"  {VERMELHO}{m['erro']}{RESET}")
        return

    aviso_amostra = f"  {AMARELO}⚠ Amostra pequena ({m['total_trades']} trades < 50){RESET}" if not m["amostra_ok"] else ""

    print(f"  Trades total   : {m['total_trades']}{aviso_amostra}")
    print(f"  Wins / Losses  : {m['wins']} / {m['loses']}")
    print(f"  Win rate       : {cor(m['win_rate'], True)}")
    print()
    print(f"  Fator de lucro : {cor(fmt_x(m['fator_lucro']), True)}  (alvo > 1.5)")
    print(f"  RRR médio      : {cor(fmt_x(m['rrr_medio']), True)}  (alvo > 2.0)")
    print(f"  Esperança/trade: {cor(fmt_rs(m['esperanca_trade']), True)}")
    print()
    print(f"  Resultado bruto: {fmt_rs(m['resultado_bruto'])}")
    print(f"  Custo total    : {fmt_rs(-m['custo_total'])}")
    print(f"  Resultado líq. : {cor(fmt_rs(m['resultado_liquido']), True)}")
    print()
    print(f"  Ganho médio    : {fmt_rs(m['media_ganho'])}")
    print(f"  Perda média    : {fmt_rs(m['media_perda'])}")
    print(f"  Max drawdown   : {cor(fmt_rs(m['max_drawdown']), False)}")
    print(f"  Max seq.perda  : {m['max_seq_perda']} trades consecutivos")
    print(f"  Duração média  : {m['duracao_media_min']:.0f} min/trade")
    if m["melhor_hora"] is not None:
        print(f"  Melhor horário : {m['melhor_hora']:02d}h")
    print()

    # Veredicto
    fl = m["fator_lucro"]
    if fl >= 1.5 and m["amostra_ok"]:
        print(f"  {VERDE}{NEGRITO}✅ APROVADO — fator {fl:.2f} ≥ 1.5{RESET}")
    elif fl >= 1.0:
        print(f"  {AMARELO}{NEGRITO}⚠  MARGINAL — fator {fl:.2f} (ajustar parâmetros){RESET}")
    else:
        print(f"  {VERMELHO}{NEGRITO}❌ REPROVADO — fator {fl:.2f} < 1.0 (perde dinheiro){RESET}")


def imprimir_comparativo(lista_metricas: list[dict]):
    print()
    print(f"{NEGRITO}{'='*80}{RESET}")
    print(f"{NEGRITO}  COMPARATIVO — {len(lista_metricas)} robôs/TFs{RESET}")
    print(f"{'='*80}")

    header = f"{'Nome':<35} {'Trades':>6} {'Win%':>6} {'FatorL':>7} {'RRR':>5} {'Resultado':>12} {'Veredicto'}"
    print(header)
    print("-" * 80)

    # Ordenar por fator de lucro decrescente
    lista_metricas = sorted(
        [m for m in lista_metricas if "erro" not in m],
        key=lambda m: m["fator_lucro"],
        reverse=True
    )

    for m in lista_metricas:
        fl = m["fator_lucro"]
        rl = m["resultado_liquido"]
        veredicto = "✅ OK" if fl >= 1.5 and m["amostra_ok"] else ("⚠ MARGINAL" if fl >= 1.0 else "❌ FALHA")
        fl_str = fmt_x(fl)
        rl_str = fmt_rs(rl)
        print(f"  {m['nome']:<33} {m['total_trades']:>6} {m['win_rate']:>5.1f}%  {fl_str:>7} {m['rrr_medio']:>5.2f}  {rl_str:>11}  {veredicto}")

    print()


def imprimir_curva_capital(ops: list[dict], nome: str, custo_por_trade: float = CUSTO_POR_TRADE_RS):
    """Imprime curva de capital simples no terminal (ASCII)."""
    if not ops:
        return

    resultados = [o["resultado_rs"] - custo_por_trade for o in ops]
    equity = []
    acum = 0
    for r in resultados:
        acum += r
        equity.append(acum)

    min_eq = min(equity)
    max_eq = max(equity)
    altura = 10
    largura = min(len(equity), 80)

    # Amostrar se muitos trades
    if len(equity) > largura:
        passo = len(equity) / largura
        equity_plot = [equity[int(i * passo)] for i in range(largura)]
    else:
        equity_plot = equity

    print(f"\n  Curva de Capital — {nome}")
    print(f"  Max: {fmt_rs(max_eq)}  |  Final: {fmt_rs(equity[-1])}")

    if max_eq == min_eq:
        print("  (sem variacao)")
        return

    grid = []
    for row in range(altura):
        linha = []
        threshold = max_eq - (row / (altura - 1)) * (max_eq - min_eq)
        for v in equity_plot:
            linha.append("█" if v >= threshold else " ")
        grid.append(linha)

    for i, linha in enumerate(grid):
        if i == 0:
            label = f"{max_eq:+.0f}"
        elif i == altura - 1:
            label = f"{min_eq:+.0f}"
        elif i == int(altura / 2):
            label = f"{(max_eq + min_eq) / 2:+.0f}"
        else:
            label = ""
        print(f"  {label:>7} |{''.join(linha)}")

    print(f"          +{'─' * len(equity_plot)}")
    print(f"           0{' ' * (len(equity_plot)//2 - 2)}trades → {len(ops)}")
    print()


# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

def processar_arquivo(filepath: str) -> dict:
    nome = os.path.splitext(os.path.basename(filepath))[0]
    print(f"\n[Lendo] {filepath} ...")
    ops = load_csv(filepath)
    if not ops:
        return {"nome": nome, "erro": "Nenhuma operacao carregada"}
    m = calcular_metricas(ops, nome=nome)
    imprimir_relatorio(m)
    imprimir_curva_capital(ops, nome)
    return m


def main():
    if len(sys.argv) < 2:
        print("Uso:")
        print("  python scripts/analisa_backtest_profit.py <arquivo.csv>")
        print("  python scripts/analisa_backtest_profit.py <pasta/>")
        sys.exit(1)

    alvo = sys.argv[1]

    if os.path.isdir(alvo):
        arquivos = sorted([
            os.path.join(alvo, f)
            for f in os.listdir(alvo)
            if f.lower().endswith(".csv")
        ])
        if not arquivos:
            print(f"Nenhum CSV encontrado em: {alvo}")
            sys.exit(1)

        print(f"\nEncontrados {len(arquivos)} arquivo(s) CSV em '{alvo}'")
        todas_metricas = []
        for arq in arquivos:
            m = processar_arquivo(arq)
            todas_metricas.append(m)

        if len(todas_metricas) > 1:
            imprimir_comparativo(todas_metricas)

    elif os.path.isfile(alvo):
        processar_arquivo(alvo)

    else:
        print(f"Arquivo ou pasta nao encontrado: {alvo}")
        sys.exit(1)


if __name__ == "__main__":
    main()
