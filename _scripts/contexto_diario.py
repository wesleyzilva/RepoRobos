"""
contexto_diario.py — Relatório matinal de contexto macro WIN
Uso: python _scripts/contexto_diario.py
     python _scripts/contexto_diario.py --ativo WINJ26
     python _scripts/contexto_diario.py --ano 2026

Saída: semáforo macro (viés do dia + tendência semanal) em ~20 linhas
       Consumo de tokens: ZERO — roda local, não vai ao chat

Dados: DadosCandlesBacktest/2024_26/WINFUT_F_0_Diário.csv
                                   WINFUT_F_0_Semanal.csv
"""

import csv
import argparse
from pathlib import Path
from datetime import datetime

# ── CONFIG ─────────────────────────────────────────────────────────────────
PASTA_BASE = Path(__file__).parent.parent / "DadosCandlesBacktest"
PERIODO    = "2024_26"
SEP        = ";"
CODPAG     = "utf-8-sig"

# Campos esperados no CSV (Profit exporta com esses nomes)
CAMPO_DATA  = "Data"
CAMPO_HORA  = "Hora"
CAMPO_OPEN  = "Abertura"
CAMPO_HIGH  = "Máxima"
CAMPO_LOW   = "Mínima"
CAMPO_CLOSE = "Fechamento"
CAMPO_VOL   = "Volume"


def _parse_float(s: str) -> float:
    """Converte string brasileira para float: '167.090,50' → 167090.5"""
    if not s:
        return 0.0
    # Remove pontos de milhar, substitui vírgula decimal por ponto
    s = s.strip()
    if "," in s:
        partes = s.split(",")
        inteiro = partes[0].replace(".", "")
        decimal = partes[1] if len(partes) > 1 else "0"
        return float(f"{inteiro}.{decimal}")
    else:
        return float(s.replace(".", ""))


def ler_csv(pasta: Path, ativo: str, tf: str) -> list[dict]:
    """
    Lê CSV de um ativo/timeframe.
    Retorna lista de dicts {dt, close, high, low, open, vol} em ordem cronológica.
    """
    fname = pasta / f"{ativo}_F_0_{tf}.csv"
    if not fname.exists():
        # tenta nome alternativo sem acento
        fname2 = pasta / f"{ativo}_F_0_Diario.csv"
        if tf == "Diário" and fname2.exists():
            fname = fname2
        else:
            return []

    rows = []
    with open(fname, encoding=CODPAG, errors="replace") as f:
        reader = csv.DictReader(f, delimiter=SEP)
        for linha in reader:
            try:
                close = _parse_float(linha.get(CAMPO_CLOSE, "0"))
                high  = _parse_float(linha.get(CAMPO_HIGH,  "0"))
                low   = _parse_float(linha.get(CAMPO_LOW,   "0"))
                vol   = _parse_float(linha.get(CAMPO_VOL,   "0"))
                dt    = linha.get(CAMPO_DATA, "").strip()
                rows.append({"dt": dt, "close": close, "high": high, "low": low, "vol": vol})
            except Exception:
                continue

    # CSV do Profit vem em ordem decrescente (mais recente primeiro) — inverter
    rows.reverse()
    return rows


def filtrar_ano(rows: list[dict], ano: int) -> list[dict]:
    """Mantém apenas registros do ano especificado ou anteriores."""
    def _ano(r):
        try:
            return int(r["dt"].split("/")[2])
        except Exception:
            return 0
    return [r for r in rows if _ano(r) <= ano]


def mme(serie: list[float], n: int) -> list[float]:
    """Média Móvel Exponencial de N períodos."""
    if not serie:
        return []
    k = 2.0 / (n + 1)
    result = []
    ema = serie[0]
    for v in serie:
        ema = v * k + ema * (1.0 - k)
        result.append(round(ema, 1))
    return result


def estrutura_pivots(closes: list[float], janela: int = 5) -> str:
    """
    Identifica tendência pela estrutura de médias em janelas consecutivas.
    ALTA = cada janela sucessivamente maior que a anterior.
    BAIXA = cada janela sucessivamente menor.
    """
    if len(closes) < janela * 3:
        return "INDEFINIDO"
    def _med(lst): return sum(lst) / len(lst)
    n = len(closes)
    p1 = _med(closes[n - janela*3 : n - janela*2])
    p2 = _med(closes[n - janela*2 : n - janela*1])
    p3 = _med(closes[n - janela*1 :])
    if p3 > p2 > p1:
        return "ALTA"
    elif p3 < p2 < p1:
        return "BAIXA"
    elif abs(p3 - p1) / p1 < 0.005:  # variação < 0.5% → lateral
        return "LATERAL"
    return "INDEFINIDO"


def sinal(cond: bool) -> str:
    return "✅" if cond else "❌"


def seta(cond: bool) -> str:
    return "📈" if cond else "📉"


# ── RELATÓRIO ───────────────────────────────────────────────────────────────

def relatorio(ativo: str = "WINFUT", ano: int = 2026):
    pasta = PASTA_BASE / PERIODO

    print()
    print("=" * 62)
    print(f"  CONTEXTO MACRO — {ativo} — {datetime.now().strftime('%d/%m/%Y %H:%M')}")
    print(f"  Dados: {PERIODO}  |  Limite: {ano}")
    print("=" * 62)

    # ────────────────────────────────── DIÁRIO
    dados_d = filtrar_ano(ler_csv(pasta, ativo, "Diário"), ano)
    if len(dados_d) < 20:
        print(f"\n⚠️  Arquivo diário não encontrado ou com menos de 20 candles.")
        print(f"   Esperado: {pasta}/{ativo}_F_0_Diário.csv")
        viés_diario = "❓"
    else:
        closes_d = [r["close"] for r in dados_d]
        mme9_d   = mme(closes_d, 9)
        mme20_d  = mme(closes_d, 20)
        mme200_d = mme(closes_d, 200) if len(closes_d) >= 200 else mme(closes_d, len(closes_d))

        c  = closes_d[-1]
        dt = dados_d[-1]["dt"]
        hi = dados_d[-1]["high"]
        lo = dados_d[-1]["low"]

        acima9   = c > mme9_d[-1]
        acima20  = c > mme20_d[-1]
        acima200 = c > mme200_d[-1]
        mme20sub = mme20_d[-1] > mme20_d[-2]
        mme9sub  = mme9_d[-1]  > mme9_d[-2]
        est_d    = estrutura_pivots(closes_d[-30:], janela=6)

        # Candle de ontem
        candle_dir = "🟢 bullish" if closes_d[-1] > closes_d[-2] else "🔴 bearish" if len(closes_d) > 1 else ""

        # ATR simplificado (média dos ranges dos últimos 14 dias)
        ranges = [dados_d[i]["high"] - dados_d[i]["low"] for i in range(-14, 0) if i < len(dados_d)]
        atr14  = round(sum(ranges) / len(ranges)) if ranges else 0

        print(f"\n📅 DIÁRIO  (ref: {dt})")
        print(f"   Close : {c:,.0f}   High: {hi:,.0f}   Low: {lo:,.0f}")
        print(f"   ATR14 : {atr14:,.0f} pts")
        print(f"   MME9  : {mme9_d[-1]:,.0f}  {sinal(acima9)} acima  {seta(mme9sub)} inclinação")
        print(f"   MME20 : {mme20_d[-1]:,.0f}  {sinal(acima20)} acima  {seta(mme20sub)} inclinação")
        print(f"   MME200: {mme200_d[-1]:,.0f}  {sinal(acima200)} acima")
        print(f"   Candle: {candle_dir}   Estrutura: {est_d}")

        # Score e viés
        votos = [acima9, acima20, acima200, mme20sub, est_d == "ALTA"]
        score = sum(votos)
        if score >= 4:
            viés_diario = "🟢 COMPRA"
        elif score <= 1:
            viés_diario = "🔴 VENDA"
        else:
            viés_diario = "🟡 NEUTRO"
        print(f"\n   ➤ VIÉS DIÁRIO: {viés_diario}  (score {score}/5)")

        # Distância da MME20 (afastamento = risco de reversão)
        dist_mme20 = round(abs(c - mme20_d[-1]))
        dist_pct   = round(dist_mme20 / mme20_d[-1] * 100, 1)
        if dist_pct > 3.0:
            print(f"   ⚠️  Afastamento da MME20: {dist_mme20:,} pts ({dist_pct}%)  → RISCO de exaustão")
        elif dist_pct < 0.5:
            print(f"   💡 Próximo da MME20: {dist_mme20:,} pts — zona de valor")

    # ────────────────────────────────── SEMANAL
    dados_s = filtrar_ano(ler_csv(pasta, ativo, "Semanal"), ano)
    if len(dados_s) < 8:
        print(f"\n⚠️  Arquivo semanal não encontrado ou com menos de 8 candles.")
        viés_semanal = "❓"
    else:
        closes_s = [r["close"] for r in dados_s]
        mme9_s   = mme(closes_s, 9)
        c_s      = closes_s[-1]
        dt_s     = dados_s[-1]["dt"]
        acima_s  = c_s > mme9_s[-1]
        mme9sub_s = mme9_s[-1] > mme9_s[-2]
        est_s    = estrutura_pivots(closes_s[-15:], janela=3)

        print(f"\n📆 SEMANAL  (ref: {dt_s})")
        print(f"   Close: {c_s:,.0f}")
        print(f"   MME9:  {mme9_s[-1]:,.0f}  {sinal(acima_s)} acima  {seta(mme9sub_s)} inclinação")
        print(f"   Estrutura: {est_s}")

        votos_s = [acima_s, mme9sub_s, est_s == "ALTA"]
        score_s = sum(votos_s)
        if score_s == 3:
            viés_semanal = "🟢 ALTA"
        elif score_s == 0:
            viés_semanal = "🔴 BAIXA"
        else:
            viés_semanal = "🟡 INDEFINIDA"
        print(f"   ➤ TENDÊNCIA SEMANAL: {viés_semanal}")

    # ────────────────────────────────── DECISÃO FINAL
    print()
    print("─" * 62)
    print("  DECISÃO CONSOLIDADA")
    print("─" * 62)
    print(f"  Day Trade:   {viés_diario}")
    print(f"  Swing Trade: ", end="")

    compra_dt  = "COMPRA" in viés_diario
    venda_dt   = "VENDA"  in viés_diario
    alta_sw    = "ALTA"   in viés_semanal
    baixa_sw   = "BAIXA"  in viés_semanal

    if compra_dt and alta_sw:
        print("✅ LONG  — semanal + diário alinhados")
        print("  → Swing: entrar em pullback para MME20 diária")
        print("  → SL Swing: abaixo do último fundo do pivô semanal")
        print(f"  → SL sugerido: ~{atr14 if 'atr14' in dir() else '---'} pts (1× ATR diário)")
    elif venda_dt and baixa_sw:
        print("✅ SHORT — semanal + diário alinhados")
        print("  → Swing: entrar em repique para MME20 diária")
        print("  → SL Swing: acima do último topo do pivô semanal")
    elif "NEUTRO" in viés_diario or "INDEFINIDA" in viés_semanal:
        print("⚠️  AGUARDAR — contexto indefinido")
        print("  → Day trade: scalp somente, mão pequena")
        print("  → Swing: NÃO entrar")
    else:
        print("⚠️  DESALINHADO — semanal e diário divergem")
        print("  → Day trade: opera a favor do Diário, mão pequena")
        print("  → Swing: NÃO entrar (risco de reversão contra o semanal)")

    print()
    print("─" * 62)
    print("  REFERENCIAS DO DIA (marcar no gráfico)")
    print("─" * 62)
    if dados_d and len(dados_d) >= 2:
        ontem = dados_d[-2]
        print(f"  Máx. ontem:  {ontem['high']:,.0f}")
        print(f"  Mín. ontem:  {ontem['low']:,.0f}")
        print(f"  Fech. ontem: {ontem['close']:,.0f}  ← referência de Ajuste")
        print(f"  MME20 hoje:  {mme20_d[-1]:,.0f}  ← zona de valor")
    print("=" * 62)
    print()


# ── MAIN ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Relatório de Contexto Macro WIN")
    parser.add_argument("--ativo", default="WINFUT", help="Código do ativo (ex: WINFUT, WINJ26)")
    parser.add_argument("--ano",   type=int, default=datetime.now().year, help="Filtrar até este ano")
    args = parser.parse_args()

    relatorio(ativo=args.ativo, ano=args.ano)
