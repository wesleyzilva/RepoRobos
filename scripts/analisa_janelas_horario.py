"""
analisa_janelas_horario.py
==========================
Analisa CSVs de backtest do Profit filtrando por janelas de horário.
Calcula assertividade, esperança e drawdown por faixa horária.

FONTES SUPORTADAS:
  1. backtest_resultados/  — CSVs exportados do Profit (já têm trades prontos)
     → Método mais rápido: filtra hora de Abertura da operação
  2. DadosCandlesBacktest/ — CSVs de candles OHLCV brutos
     → Método mais lento: simula F=MA + zonas do zero (requer --modo candles)

JANELAS PADRÃO (configuráveis em JANELAS abaixo):
  - Abertura:    09:00-09:59  (violinadas, samba)
  - Manhã:       10:00-11:59  (normalização + NYSE abertura)
  - Almoço:      12:00-13:59  (baixa liquidez)
  - Tarde Prime: 14:00-17:29  ⭐ (melhor assertividade confirmada 2025)
  - Fechamento:  17:30-18:00  (encerramento forçado)

Uso:
    # Analisa pasta inteira de backtest_resultados:
    python scripts/analisa_janelas_horario.py backtest_resultados/abril_confluencia_RoboSeguro_v002/

    # Analisa um arquivo específico:
    python scripts/analisa_janelas_horario.py backtest_resultados/abril_confluencia_RoboSeguro_v002/abril_confluencia_RoboSeguro_v002_5m.csv

    # Compara todas as subpastas de backtest_resultados:
    python scripts/analisa_janelas_horario.py backtest_resultados/

Requisitos: Python 3.8+  (sem dependências externas)
"""

import csv
import os
import sys
from collections import defaultdict
from datetime import datetime, time

# ---------------------------------------------------------------------------
# JANELAS DE HORÁRIO — ajuste conforme necessário
# ---------------------------------------------------------------------------
JANELAS = [
    ("Abertura    ", time(9,  0), time(9, 59)),   # ruído, samba
    ("Manhã       ", time(10, 0), time(11, 59)),   # normalização + NYSE
    ("Almoço      ", time(12, 0), time(13, 59)),   # baixa liquidez
    ("Tarde Prime ", time(14, 0), time(17, 29)),   # ⭐ melhor assertividade
    ("Fechamento  ", time(17,30), time(18,  0)),   # encerramento
    ("Fora Pregão ", time(18, 1), time(8, 59)),    # fora do horário B3
]

# Mínimo de trades para considerar a janela estatisticamente válida
MIN_TRADES_VALIDO = 5

# Ponto de corte de resultado: acima = ganho, abaixo = perda
# Para WIN: resultado em R$ (coluna Res. Intervalo Bruto)
RESULTADO_ZERO = 0.0

# ---------------------------------------------------------------------------
# PARSING DO CSV DO PROFIT
# ---------------------------------------------------------------------------

def detect_encoding(filepath):
    try:
        with open(filepath, encoding="utf-8") as f:
            f.read()
        return "utf-8"
    except UnicodeDecodeError:
        return "latin-1"


def parse_br_number(s):
    if not s or str(s).strip() in ("", "-", " - "):
        return 0.0
    s = str(s).strip().replace(" ", "")
    neg = s.startswith("-")
    s = s.lstrip("-")
    if "," in s and "." in s:
        s = s.replace(".", "").replace(",", ".")
    elif "," in s:
        s = s.replace(",", ".")
    try:
        v = float(s)
        return -v if neg else v
    except ValueError:
        return 0.0


def parse_datetime(s):
    if not s or str(s).strip() in ("", "-", " - "):
        return None
    s = str(s).strip()
    for fmt in ["%d/%m/%Y %H:%M:%S", "%d/%m/%Y %H:%M", "%d/%m/%Y",
                "%Y-%m-%d %H:%M:%S", "%Y-%m-%d %H:%M", "%Y-%m-%d"]:
        try:
            return datetime.strptime(s, fmt)
        except ValueError:
            continue
    return None


def encontrar_coluna(headers, candidatos):
    """Encontra índice da coluna por lista de nomes candidatos (case-insensitive)."""
    for i, h in enumerate(headers):
        h_clean = h.strip().lower()
        for c in candidatos:
            if c in h_clean:
                return i
    return None


def ler_trades_profit(filepath):
    """
    Lê CSV exportado do Profit e retorna lista de dicts com campos:
    abertura (datetime), resultado_rs (float), lado (str), ativo (str)
    """
    enc = detect_encoding(filepath)
    trades = []

    with open(filepath, encoding=enc, errors="replace") as f:
        # Pular linhas de cabeçalho (Conta, Titular, Data Inicial...)
        linhas = f.readlines()

    # Encontrar a linha de headers (começa com "Ativo;")
    idx_header = None
    for i, linha in enumerate(linhas):
        if linha.strip().startswith("Ativo"):
            idx_header = i
            break

    if idx_header is None:
        return trades  # formato não reconhecido

    sep = ";" if linhas[idx_header].count(";") > linhas[idx_header].count(",") else ","
    reader = csv.reader(linhas[idx_header:], delimiter=sep)
    headers = [h.strip() for h in next(reader)]

    # Mapear colunas
    i_ativo     = encontrar_coluna(headers, ["ativo"])
    i_abertura  = encontrar_coluna(headers, ["abertura"])
    i_fechamento= encontrar_coluna(headers, ["fechamento"])
    i_lado      = encontrar_coluna(headers, ["lado"])
    i_resultado = encontrar_coluna(headers, ["res. intervalo bruto", "resultado"])
    i_total     = encontrar_coluna(headers, ["total"])

    if i_abertura is None:
        print(f"  [ERRO] Coluna 'Abertura' não encontrada em {filepath}")
        return trades

    for row in reader:
        if not row or len(row) < 3:
            continue
        try:
            ativo    = row[i_ativo].strip()    if i_ativo    is not None else ""
            abertura = parse_datetime(row[i_abertura]) if i_abertura is not None else None
            fechamento = parse_datetime(row[i_fechamento]) if i_fechamento is not None else None
            lado     = row[i_lado].strip()     if i_lado     is not None else ""
            resultado = parse_br_number(row[i_resultado]) if i_resultado is not None else 0.0

            if abertura is None:
                continue

            # Operação ainda aberta (sem fechamento) — pular
            if fechamento is None and (i_fechamento is not None and
               row[i_fechamento].strip() in ("", "-", " - ")):
                continue

            trades.append({
                "ativo":      ativo,
                "abertura":   abertura,
                "fechamento": fechamento,
                "lado":       lado,
                "resultado":  resultado,
            })
        except (IndexError, ValueError):
            continue

    return trades


# ---------------------------------------------------------------------------
# CLASSIFICAÇÃO POR JANELA
# ---------------------------------------------------------------------------

def classificar_janela(dt):
    """Retorna nome da janela para um datetime."""
    if dt is None:
        return "Sem hora"
    h = dt.time()
    for nome, inicio, fim in JANELAS:
        # Janela "Fora Pregão" tem início > fim (wrap overnight)
        if inicio <= fim:
            if inicio <= h <= fim:
                return nome
        else:
            if h >= inicio or h <= fim:
                return nome
    return "Outros     "


def calcular_metricas(trades):
    """Calcula assertividade, esperança e drawdown para uma lista de trades."""
    if not trades:
        return None

    resultados = [t["resultado"] for t in trades]
    total      = len(resultados)
    ganhos     = [r for r in resultados if r > RESULTADO_ZERO]
    perdas     = [r for r in resultados if r <= RESULTADO_ZERO]

    n_ganho    = len(ganhos)
    n_perda    = len(perdas)
    assertiv   = n_ganho / total if total > 0 else 0.0

    media_ganho = sum(ganhos) / len(ganhos) if ganhos else 0.0
    media_perda = sum(perdas) / len(perdas) if perdas else 0.0

    esperanca  = assertiv * media_ganho + (1 - assertiv) * media_perda

    # Drawdown: máxima sequência de perdas acumuladas
    pior_seq = 0.0
    acum = 0.0
    for r in resultados:
        acum += r
        if acum < pior_seq:
            pior_seq = acum
        if acum > 0:
            acum = 0.0  # reset ao voltar pro positivo

    return {
        "total":        total,
        "ganhos":       n_ganho,
        "perdas":       n_perda,
        "assertiv_pct": assertiv * 100,
        "media_ganho":  media_ganho,
        "media_perda":  media_perda,
        "esperanca":    esperanca,
        "drawdown":     pior_seq,
        "resultado_total": sum(resultados),
    }


# ---------------------------------------------------------------------------
# RELATÓRIO
# ---------------------------------------------------------------------------

def imprimir_relatorio(nome_arquivo, trades):
    print(f"\n{'='*70}")
    print(f"  {nome_arquivo}")
    print(f"  Total trades: {len(trades)}")
    if trades:
        datas = [t["abertura"] for t in trades if t["abertura"]]
        if datas:
            print(f"  Período: {min(datas).strftime('%d/%m/%Y')} → {max(datas).strftime('%d/%m/%Y')}")
    print(f"{'='*70}")

    if not trades:
        print("  Nenhuma operação encontrada.")
        return

    # Agrupar por janela
    por_janela = defaultdict(list)
    for t in trades:
        janela = classificar_janela(t["abertura"])
        por_janela[janela].append(t)

    # Cabeçalho da tabela
    print(f"\n{'Janela':<16} {'N':>4} {'Ganhos':>7} {'Perdas':>7} {'Assert%':>8} "
          f"{'MédGanho':>10} {'MédPerda':>10} {'Esperança':>10} {'Drawdown':>10} {'Status':>10}")
    print("-" * 98)

    # Linha por janela
    for nome, inicio, fim in JANELAS:
        trades_janela = por_janela.get(nome, [])
        m = calcular_metricas(trades_janela)
        if m is None:
            print(f"  {nome:<14} {'—':>4}")
            continue

        status = ""
        if m["total"] < MIN_TRADES_VALIDO:
            status = "⚠️ poucos"
        elif m["assertiv_pct"] >= 50 and m["esperanca"] > 0:
            status = "✅ bom"
        elif m["esperanca"] > 0:
            status = "🟡 ok"
        else:
            status = "❌ ruim"

        print(f"  {nome:<14} {m['total']:>4} {m['ganhos']:>7} {m['perdas']:>7} "
              f"{m['assertiv_pct']:>7.1f}% "
              f"{m['media_ganho']:>10.0f} {m['media_perda']:>10.0f} "
              f"{m['esperanca']:>10.0f} {m['drawdown']:>10.0f}  {status}")

    # Totais gerais
    print("-" * 98)
    m_total = calcular_metricas(trades)
    if m_total:
        print(f"  {'TOTAL GERAL':<14} {m_total['total']:>4} {m_total['ganhos']:>7} "
              f"{m_total['perdas']:>7} {m_total['assertiv_pct']:>7.1f}% "
              f"{m_total['media_ganho']:>10.0f} {m_total['media_perda']:>10.0f} "
              f"{m_total['esperanca']:>10.0f} {m_total['drawdown']:>10.0f}")
        print(f"\n  Resultado total bruto: R$ {m_total['resultado_total']:.2f}")

    # Recomendação automática
    print(f"\n  {'─'*60}")
    print(f"  ANÁLISE POR JANELA:")
    melhor = None
    melhor_e = float("-inf")
    for nome, _, _ in JANELAS:
        trades_janela = por_janela.get(nome, [])
        m = calcular_metricas(trades_janela)
        if m and m["total"] >= MIN_TRADES_VALIDO and m["esperanca"] > melhor_e:
            melhor_e = m["esperanca"]
            melhor = nome
    if melhor:
        print(f"  ⭐ Melhor janela: {melhor.strip()} (E = R$ {melhor_e:.0f}/op)")
    else:
        print(f"  ⚠️  Amostra insuficiente para recomendação (mín {MIN_TRADES_VALIDO} trades/janela)")
    print()


# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

def processar_arquivo(filepath):
    trades = ler_trades_profit(filepath)
    nome = os.path.basename(filepath)
    imprimir_relatorio(nome, trades)
    return trades


def processar_pasta(dirpath):
    """Processa todos os CSVs em uma pasta (não recursivo)."""
    todos_trades = []
    arquivos_csv = [
        os.path.join(dirpath, f)
        for f in sorted(os.listdir(dirpath))
        if f.lower().endswith(".csv")
    ]

    if not arquivos_csv:
        print(f"Nenhum CSV encontrado em {dirpath}")
        return

    for fp in arquivos_csv:
        trades = ler_trades_profit(fp)
        nome = os.path.basename(fp)
        imprimir_relatorio(nome, trades)
        todos_trades.extend(trades)

    if len(arquivos_csv) > 1:
        print(f"\n{'#'*70}")
        print(f"  CONSOLIDADO — todos os arquivos da pasta")
        print(f"{'#'*70}")
        imprimir_relatorio("CONSOLIDADO", todos_trades)


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        print("\nUso: python scripts/analisa_janelas_horario.py <arquivo_ou_pasta>")
        sys.exit(1)

    caminho = sys.argv[1]
    # Ajuste para path relativo à raiz do projeto
    if not os.path.isabs(caminho):
        root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        caminho = os.path.join(root, caminho)

    if os.path.isdir(caminho):
        # Verifica se é pasta direta de resultados ou pasta com subpastas
        subpastas = [
            os.path.join(caminho, d)
            for d in sorted(os.listdir(caminho))
            if os.path.isdir(os.path.join(caminho, d))
            and not d.startswith(".")
        ]
        csvs_diretos = [
            f for f in os.listdir(caminho) if f.lower().endswith(".csv")
        ]
        if subpastas and not csvs_diretos:
            # pasta raiz com subpastas de robôs
            for sp in subpastas:
                processar_pasta(sp)
        else:
            processar_pasta(caminho)
    elif os.path.isfile(caminho):
        processar_arquivo(caminho)
    else:
        print(f"[ERRO] Caminho não encontrado: {caminho}")
        sys.exit(1)


if __name__ == "__main__":
    main()
