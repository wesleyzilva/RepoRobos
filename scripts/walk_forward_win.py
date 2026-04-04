"""
walk_forward_win.py
===================
Walk-Forward Analysis para WINFUT -- estrategia F=MA + ATR x 1.2

Simula a estrategia F=MA com proxy multi-TF em dados historicos reais,
dividindo em periodos de TREINO e TESTE para detectar overfitting.

--- O QUE E WALK-FORWARD ----------------------------------------------------
  O Walk-Forward divide seus dados em periodos sequenciais:
    TREINO -> onde o robo foi calibrado ou desenvolvido
    TESTE  -> dados que o robo NUNCA VIU durante o desenvolvimento

  Se o resultado no TESTE for ? 60% do TREINO -> robusto, pode operar
  Se cair abaixo de 60% -> overfitting, nao confiar no backtest completo

  Exemplo:
    TREINO (2020_22): PF = 1.6, Esperanca = +18 pts/trade  ? parece otimo
    TESTE  (2022_24): PF = 1.3, Esperanca = +10 pts/trade  ? 56% -> reprovado!
    TESTE  (2024_26): PF = 1.4, Esperanca = +12 pts/trade  ? 67% -> aprovado!

--- ESTRATEGIA SIMULADA -----------------------------------------------------
  TF: 15min (disponivel em todos os periodos)
  Entrada Long:
    - F=MA >= FORCA_MIN (corpo/range x vol/volmedia x 100)
    - Close > Media(JANELA_DIR) e Media(JANELA_DIR) sobe  ? proxy TF direcao
    - Close > Media(JANELA_CTX) e Media(JANELA_CTX) sobe ? proxy TF contexto
    - Volume >= media20 x VOL_MULT
  Entrada Short: simetrico
  Stop: ATR(14) x ATR_STOP_MULT abaixo da entrada
  Alvo: ATR(14) x ATR_ALVO_MULT acima da entrada (RRR fixo)
  Horario: so candles com hora entre HORA_INI e HORA_FIM

--- USO ---------------------------------------------------------------------
  python scripts/walk_forward_win.py
  python scripts/walk_forward_win.py --forca 60 --rrr 2.5

--- REQUISITOS --------------------------------------------------------------
  Python 3.8+ | sem dependencias externas
"""

import csv
import os
import sys
import math
import statistics
import argparse
from collections import defaultdict

# Forcar UTF-8 no Windows (console cp1252 nao suporta acentos/unicode)
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

# --- CAMINHOS ----------------------------------------------------------------
BASE_DIR    = os.path.join(os.path.dirname(__file__), '..', 'DadosCandlesBacktest')
ATIVO       = 'WINFUT'
TF          = '15min'   # unico TF disponivel em todos os periodos

# Sequencia cronologica de treino/teste
PERIODOS = ['2020_22', '2022_24', '2024_26']

# --- PARAMETROS PADRAO DA ESTRATEGIA -----------------------------------------
# Altere aqui ou use --flags na linha de comando para experimentar
FORCA_MIN     = 55.0   # threshold F=MA para entrada
JANELA_DIR    = 2      # proxy TF2 (direcao) -- candles do TF atual
JANELA_CTX    = 4      # proxy TF1 (contexto) -- candles do TF atual
ATR_PERIODO   = 14     # periodo do ATR
ATR_STOP_MULT = 1.2    # SL = ATR x 1.2 (calibrado dados reais 2020-2026)
ATR_ALVO_MULT = 2.4    # TP = ATR x 2.4 (RRR 2.0)
VOL_MULT      = 1.5    # volume minimo = media20 x 1.5
HORA_INI      = 9      # hora inicio operacional (inclusive)
HORA_FIM      = 17     # hora fim operacional (inclusive)

# Limiar de aprovacao walk-forward
WF_LIMIAR = 0.60       # resultado teste >= 60% do treino = aprovado


# --- LEITURA DO CSV ------------------------------------------------------------
def ler_csv(pasta: str, ativo: str, tf: str) -> list[dict]:
    """Le CSV de candles (formato Profit/Neologica) e retorna lista de dicts."""
    path = os.path.join(BASE_DIR, pasta, f'{ativo}_F_0_{tf}.csv')
    if not os.path.exists(path):
        return []
    rows = []
    with open(path, encoding='latin1') as f:
        f.readline()  # pular header
        for line in f:
            cols = line.strip().split(';')
            if len(cols) < 8:
                continue
            try:
                hora_str = cols[2] if len(cols) > 2 else '0:0:0'
                hora = int(hora_str.split(':')[0])
                def pf(s: str) -> float:
                    return float(s.replace('.', '').replace(',', '.'))
                rows.append({
                    'hora': hora,
                    'a':  pf(cols[3]),  # abertura
                    'mx': pf(cols[4]),  # maximo
                    'mn': pf(cols[5]),  # minimo
                    'f':  pf(cols[6]),  # fechamento
                    'v':  pf(cols[7]),  # volume
                })
            except Exception:
                continue
    return rows


# --- INDICADORES ----------------------------------------------------------------
def calc_atr(rows: list[dict], idx: int, periodo: int) -> float:
    """ATR(periodo) na posicao idx."""
    if idx < periodo:
        return 0.0
    trs = []
    for i in range(idx - periodo + 1, idx + 1):
        tr = max(
            rows[i]['mx'] - rows[i]['mn'],
            abs(rows[i]['mx'] - rows[i - 1]['f']),
            abs(rows[i]['mn'] - rows[i - 1]['f']),
        )
        trs.append(tr)
    return statistics.mean(trs)


def calc_media(rows: list[dict], idx: int, janela: int) -> float:
    """Media simples do fechamento nos ultimos `janela` candles."""
    if idx < janela - 1:
        return 0.0
    vals = [rows[i]['f'] for i in range(idx - janela + 1, idx + 1)]
    return statistics.mean(vals)


def calc_forca(r: dict, vmedia: float) -> float:
    """F=MA = (|corpo|/range) x (volume/vmedia) x 100, limitado a ?100."""
    rng = r['mx'] - r['mn']
    if rng < 0.01:
        return 0.0
    massa = abs(r['f'] - r['a']) / rng
    vrat  = r['v'] / vmedia if vmedia > 0 else 0.0
    f = massa * vrat * 100.0
    return min(max(f, -100.0), 100.0)


# --- SIMULACAO -----------------------------------------------------------------
def simular(rows: list[dict],
            forca_min:     float = FORCA_MIN,
            janela_dir:    int   = JANELA_DIR,
            janela_ctx:    int   = JANELA_CTX,
            atr_periodo:   int   = ATR_PERIODO,
            atr_stop_mult: float = ATR_STOP_MULT,
            atr_alvo_mult: float = ATR_ALVO_MULT,
            vol_mult:      float = VOL_MULT,
            hora_ini:      int   = HORA_INI,
            hora_fim:      int   = HORA_FIM) -> list[float]:
    """
    Simula a estrategia e retorna lista de resultados em pontos por trade.
    Positivo = ganho, negativo = perda.
    """
    n = len(rows)
    vol_periodo = 20  # media de volume para filtro
    resultados: list[float] = []

    # Precisamos de warmup: max(atr_periodo, janela_ctx, vol_periodo) + buffer
    warmup = max(atr_periodo, janela_ctx * 2, vol_periodo) + 5

    em_posicao = False
    direcao    = 0      # +1 long, -1 short
    entrada    = 0.0
    stop       = 0.0
    alvo       = 0.0

    for i in range(warmup, n - 1):
        r = rows[i]

        # Filtro de horario
        if not (hora_ini <= r['hora'] <= hora_fim):
            # Fechar posicao se horario encerrou
            if em_posicao:
                resultado = (r['f'] - entrada) * direcao
                resultados.append(resultado)
                em_posicao = False
            continue

        # Verificar saida se estamos em posicao (verifica no PROXIMO candle)
        if em_posicao:
            prox = rows[i + 1]
            # Verificar se SL ou TP foi atingido no proximo candle
            if direcao == 1:   # long
                if prox['mn'] <= stop:
                    resultados.append(stop - entrada)
                    em_posicao = False
                    continue
                elif prox['mx'] >= alvo:
                    resultados.append(alvo - entrada)
                    em_posicao = False
                    continue
                # Ainda em posicao -- continua
            else:               # short
                if prox['mx'] >= stop:
                    resultados.append(entrada - stop)
                    em_posicao = False
                    continue
                elif prox['mn'] <= alvo:
                    resultados.append(entrada - alvo)
                    em_posicao = False
                    continue
            continue  # posicao aberta, nao entra novamente

        # -- Calcular indicadores ------------------------------------------
        atr = calc_atr(rows, i, atr_periodo)
        if atr <= 0:
            continue

        vmedia = statistics.mean(rows[j]['v'] for j in range(i - vol_periodo + 1, i + 1))
        forca  = calc_forca(r, vmedia)

        media_dir     = calc_media(rows, i, janela_dir)
        media_dir_ant = calc_media(rows, i - janela_dir, janela_dir)
        media_ctx     = calc_media(rows, i, janela_ctx)
        media_ctx_ant = calc_media(rows, i - janela_ctx, janela_ctx)

        dir_alta   = (r['f'] > media_dir)    and (media_dir > media_dir_ant)
        ctx_alta   = (r['f'] > media_ctx)    and (media_ctx > media_ctx_ant)
        dir_baixa  = (r['f'] < media_dir)    and (media_dir < media_dir_ant)
        ctx_baixa  = (r['f'] < media_ctx)    and (media_ctx < media_ctx_ant)

        vol_ok = r['v'] >= vmedia * vol_mult

        # -- Sinal de entrada ----------------------------------------------
        if forca >= forca_min and dir_alta and ctx_alta and vol_ok:
            # Entrada long
            direcao   = 1
            entrada   = r['f']
            stop      = entrada - atr * atr_stop_mult
            alvo      = entrada + atr * atr_alvo_mult
            em_posicao = True

        elif (-forca) >= forca_min and dir_baixa and ctx_baixa and vol_ok:
            # Entrada short
            direcao   = -1
            entrada   = r['f']
            stop      = entrada + atr * atr_stop_mult
            alvo      = entrada - atr * atr_alvo_mult
            em_posicao = True

    # Fechar posicao aberta no ultimo candle
    if em_posicao:
        resultado = (rows[-1]['f'] - entrada) * direcao
        resultados.append(resultado)

    return resultados


# --- METRICAS -------------------------------------------------------------------
def calcular_metricas(trades: list[float]) -> dict:
    """Calcula metricas completas de performance."""
    if not trades:
        return {'n': 0, 'status': 'sem_trades'}

    n       = len(trades)
    ganhos  = [t for t in trades if t > 0]
    perdas  = [t for t in trades if t < 0]
    n_g     = len(ganhos)
    n_p     = len(perdas)

    win_rate    = n_g / n if n > 0 else 0.0
    media_g     = statistics.mean(ganhos) if ganhos else 0.0
    media_p     = abs(statistics.mean(perdas)) if perdas else 0.0
    rrr         = media_g / media_p if media_p > 0 else 0.0
    esperanca   = win_rate * media_g - (1 - win_rate) * media_p

    soma_g      = sum(ganhos)
    soma_p      = abs(sum(perdas))
    pf          = soma_g / soma_p if soma_p > 0 else 999.0

    # Kelly
    kelly_raw = win_rate - (1 - win_rate) / rrr if rrr > 0 else 0.0
    kelly     = max(0.0, kelly_raw)
    half_kelly = kelly / 2

    # IC 95% do PF (aproximacao)
    ic_margem = 1.96 * pf / math.sqrt(n) if n > 0 else 0.0
    ic_inf    = pf - ic_margem
    ic_sup    = pf + ic_margem

    # t-stat da esperanca
    if n > 1:
        std_trades = statistics.stdev(trades)
        t_stat = esperanca / (std_trades / math.sqrt(n)) if std_trades > 0 else 0.0
    else:
        t_stat = 0.0

    return {
        'n':          n,
        'n_ganhos':   n_g,
        'n_perdas':   n_p,
        'win_rate':   win_rate,
        'media_g':    media_g,
        'media_p':    media_p,
        'rrr':        rrr,
        'esperanca':  esperanca,
        'pf':         pf,
        'ic_inf':     ic_inf,
        'ic_sup':     ic_sup,
        't_stat':     t_stat,
        'kelly':      kelly,
        'half_kelly': half_kelly,
        'soma_g':     soma_g,
        'soma_p':     soma_p,
    }


def ic_status(m: dict) -> str:
    """Veredicto simples por criterio."""
    if m['n'] < 30:
        return '(!) amostra pequena'
    checks = [
        m['esperanca'] > 0,
        m['pf'] >= 1.3,
        m['ic_inf'] > 1.0,
        m['t_stat'] > 1.645,
    ]
    ok = sum(checks)
    if ok == 4:
        return '[OK] APROVADO (4/4)'
    if ok >= 3:
        return '[!!] PARCIAL  (3/4)'
    return '[XX] REPROVADO'


def razao_wf(m_treino: dict, m_teste: dict, campo: str = 'esperanca') -> float | None:
    """Razao teste/treino para um campo. None se treino invalido."""
    t = m_treino.get(campo, 0)
    v = m_teste.get(campo, 0)
    if t <= 0:
        return None
    return v / t


# --- FORMATACAO -----------------------------------------------------------------
def fmt_metricas(label: str, m: dict) -> str:
    if m.get('n', 0) == 0:
        return f'  {label}: sem dados'
    return (
        f'  {label}:\n'
        f'    Trades  : {m["n"]:>5}  |  Ganhos: {m["n_ganhos"]:>4}  |  Perdas: {m["n_perdas"]:>4}\n'
        f'    Win rate: {m["win_rate"]*100:>5.1f}%  |  RRR   : {m["rrr"]:>5.2f}\n'
        f'    Esperanc: {m["esperanca"]:>+7.1f} pts/trade\n'
        f'    PF      : {m["pf"]:>5.2f}   |  IC95%: [{m["ic_inf"]:>5.2f}, {m["ic_sup"]:>5.2f}]\n'
        f'    t-stat  : {m["t_stat"]:>5.2f}   |  Kelly: {m["kelly"]*100:>4.1f}%  HalfKelly: {m["half_kelly"]*100:>4.1f}%\n'
        f'    Status  : {ic_status(m)}'
    )


# --- MAIN ------------------------------------------------------------------------
def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description='Walk-Forward Analysis -- WINFUT F=MA')
    p.add_argument('--forca',     type=float, default=FORCA_MIN,     help=f'F=MA minimo (default {FORCA_MIN})')
    p.add_argument('--stop-mult', type=float, default=ATR_STOP_MULT, help=f'ATRxmult SL (default {ATR_STOP_MULT})')
    p.add_argument('--alvo-mult', type=float, default=ATR_ALVO_MULT, help=f'ATRxmult TP (default {ATR_ALVO_MULT})')
    p.add_argument('--vol-mult',  type=float, default=VOL_MULT,      help=f'Volxmult filtro (default {VOL_MULT})')
    p.add_argument('--janela-dir',type=int,   default=JANELA_DIR,    help=f'Janela proxy TF2 (default {JANELA_DIR})')
    p.add_argument('--janela-ctx',type=int,   default=JANELA_CTX,    help=f'Janela proxy TF1 (default {JANELA_CTX})')
    p.add_argument('--tf',        type=str,   default=TF,            help=f'Timeframe CSV (default {TF})')
    return p.parse_args()


def main() -> None:
    args = parse_args()

    # Garantir saida UTF-8 no Windows (cp1252 nao suporta Unicode)
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8', errors='replace')

    print()
    print('=' * 68)
    print('  WALK-FORWARD ANALYSIS -- WINFUT F=MA + ATR x 1.2')
    print('=' * 68)
    print(f'  Estrategia : F=MA >= {args.forca} | MultiTF janelas Dir={args.janela_dir} Ctx={args.janela_ctx}')
    print(f'  Stop/Alvo  : ATR x {args.stop_mult} / ATR x {args.alvo_mult}  (RRR={args.alvo_mult/args.stop_mult:.1f})')
    print(f'  Filtro Vol : Vol >= Media20 x {args.vol_mult}')
    print(f'  TF         : {args.tf}  |  Horario: {HORA_INI}h-{HORA_FIM}h')
    print()

    # -- Carregar dados de cada periodo --------------------------------------
    dados: dict[str, list[dict]] = {}
    for periodo in PERIODOS:
        rows = ler_csv(periodo, ATIVO, args.tf)
        dados[periodo] = rows
        status = f'{len(rows):>6} candles' if rows else 'NAO ENCONTRADO'
        print(f'  {periodo}: {status}')
    print()

    # -- Simular cada periodo individualmente --------------------------------
    resultados_por_periodo: dict[str, list[float]] = {}
    metricas_por_periodo:   dict[str, dict]        = {}

    print('-' * 68)
    print('  RESULTADO POR PERIODO (backtest completo)')
    print('-' * 68)

    for periodo in PERIODOS:
        rows = dados[periodo]
        if not rows:
            print(f'\n  {periodo}: sem dados -- pulando')
            continue
        trades = simular(
            rows,
            forca_min     = args.forca,
            janela_dir    = args.janela_dir,
            janela_ctx    = args.janela_ctx,
            atr_stop_mult = args.stop_mult,
            atr_alvo_mult = args.alvo_mult,
            vol_mult      = args.vol_mult,
        )
        resultados_por_periodo[periodo] = trades
        m = calcular_metricas(trades)
        metricas_por_periodo[periodo] = m
        print()
        print(fmt_metricas(periodo, m))

    # -- Walk-Forward: Treino -> Teste sequencial -----------------------------
    print()
    print('=' * 68)
    print('  WALK-FORWARD -- COMPARATIVO TREINO / TESTE')
    print(f'  Criterio aprovacao: resultado teste >= {WF_LIMIAR*100:.0f}% do treino')
    print('=' * 68)

    wf_pares = [
        ('2020_22', '2022_24', 'WF1'),
        ('2022_24', '2024_26', 'WF2'),
    ]

    for treino_p, teste_p, label in wf_pares:
        m_tr = metricas_por_periodo.get(treino_p)
        m_te = metricas_por_periodo.get(teste_p)
        if not m_tr or not m_te:
            print(f'\n  {label}: dados insuficientes')
            continue

        print()
        print(f'  -- {label}: Treino={treino_p} -> Teste={teste_p}')
        print()
        print(fmt_metricas(f'  TREINO ({treino_p})', m_tr))
        print()
        print(fmt_metricas(f'  TESTE  ({teste_p})', m_te))
        print()

        # Razoes treino/teste para indicadores-chave
        razao_esp = razao_wf(m_tr, m_te, 'esperanca')
        razao_pf  = razao_wf(m_tr, m_te, 'pf')

        if razao_esp is None:
            print(f'  Razao WF (esperanca): treino negativo -- nao comparavel')
        else:
            pct_esp = razao_esp * 100
            ok_esp  = razao_esp >= WF_LIMIAR
            pct_pf  = (razao_pf * 100) if razao_pf else 0.0
            ok_pf   = (razao_pf >= WF_LIMIAR) if razao_pf else False

            print(f'  Razao teste/treino (esperanca) : {pct_esp:>6.1f}%  {"[OK]" if ok_esp else "[XX]"}')
            print(f'  Razao teste/treino (PF)        : {pct_pf:>6.1f}%  {"[OK]" if ok_pf else "[XX]"}')
            print()

            if ok_esp and ok_pf:
                print(f'  [PASS] {label} APROVADO -- estrategia manteve >= {WF_LIMIAR*100:.0f}% da performance no periodo nao visto')
            elif ok_esp or ok_pf:
                print(f'  [WARN] {label} PARCIAL  -- um criterio passou, revisar setup antes de operar real')
            else:
                print(f'  [FAIL] {label} REPROVADO -- performance caiu abaixo de {WF_LIMIAR*100:.0f}% no periodo de teste')
                print(f'     -> Provavel overfitting ao periodo de treino')
                print(f'     -> Nao usar em conta real sem ajustar parametros')

    # -- Walk-Forward expandido: treino combinado -----------------------------
    print()
    print('-' * 68)
    print('  WF3: Treino COMBINADO (2020_22 + 2022_24) -> Teste 2024_26')
    print('-' * 68)

    rows_treino_comb = dados.get('2020_22', []) + dados.get('2022_24', [])
    rows_teste_fin   = dados.get('2024_26', [])

    if rows_treino_comb and rows_teste_fin:
        trades_comb = simular(rows_treino_comb, forca_min=args.forca,
                              janela_dir=args.janela_dir, janela_ctx=args.janela_ctx,
                              atr_stop_mult=args.stop_mult, atr_alvo_mult=args.alvo_mult,
                              vol_mult=args.vol_mult)
        trades_fin  = simular(rows_teste_fin,  forca_min=args.forca,
                              janela_dir=args.janela_dir, janela_ctx=args.janela_ctx,
                              atr_stop_mult=args.stop_mult, atr_alvo_mult=args.alvo_mult,
                              vol_mult=args.vol_mult)

        m_comb = calcular_metricas(trades_comb)
        m_fin  = calcular_metricas(trades_fin)

        print()
        print(fmt_metricas('  TREINO combinado (2020_22+2022_24)', m_comb))
        print()
        print(fmt_metricas('  TESTE final      (2024_26)', m_fin))
        print()

        razao_esp = razao_wf(m_comb, m_fin, 'esperanca')
        razao_pf  = razao_wf(m_comb, m_fin, 'pf')

        if razao_esp and razao_pf:
            ok = razao_esp >= WF_LIMIAR and razao_pf >= WF_LIMIAR
            print(f'  Razao teste/treino (esperanca) : {razao_esp*100:>6.1f}%  {"[OK]" if razao_esp >= WF_LIMIAR else "[XX]"}')
            print(f'  Razao teste/treino (PF)        : {razao_pf*100:>6.1f}%  {"[OK]" if razao_pf >= WF_LIMIAR else "[XX]"}')
            print()
            veredicto = '[PASS] WF3 APROVADO' if ok else '[FAIL] WF3 REPROVADO'
            print(f'  {veredicto}')

    # -- Resumo final ---------------------------------------------------------
    print()
    print('-' * 68)
    print('  RESUMO -- CRITERIOS MINIMOS PARA OPERAR EM CONTA REAL')
    print('  (skill_probabilidade_operacional.md)')
    print('-' * 68)
    print()
    print('  Criterio            Minimo    Ideal')
    print('  -----------------------------------------------------')
    print('  N trades             >= 100   >= 200')
    print('  Esperanca            >  0     > 10 pts/trade')
    print('  PF                   >= 1.3   >= 1.5')
    print('  IC 95% inferior      >  1.0   > 1.15')
    print('  t-stat               > 1.645  > 2.0')
    print('  Walk-Forward         >= 60%   >= 80%')
    print()
    print('  Rode novamente com --forca, --stop-mult para otimizar parametros')
    print('  Exemplos:')
    print('    python scripts/walk_forward_win.py --forca 60 --stop-mult 1.0 --alvo-mult 2.0')
    print('    python scripts/walk_forward_win.py --forca 50 --vol-mult 2.0')
    print('=' * 68)
    print()


if __name__ == '__main__':
    main()
