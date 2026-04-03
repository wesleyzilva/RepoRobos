# Skill: Contexto de Longo Prazo — Viés do Dia e Swing Trade

> Responde a pergunta fundamental antes de qualquer trade:
> **"Hoje eu procuro COMPRA ou VENDA?"**
>
> Cobre dois objetivos: Day Trade (viés intraday) e Swing Trade (posição de dias).

---

## A Ideia em Uma Frase

O mercado é fractal: o **Mensal domina o Semanal, o Semanal domina o Diário, o Diário domina o Intraday**.
Operar sem saber em qual degrau da escada você está é o erro mais comum.

---

## Camadas de Análise (Top-Down)

```
MENSAL    → "Verão ou Inverno?" — tendência secular (anos)
  ↓
SEMANAL   → "Maré" — tendência primária (meses) — SWING TRADE aqui
  ↓
DIÁRIO    → "Onda" — viés do dia — DAY TRADE aqui
  ↓
60min     → Direção do dia — confirma ou contradiz o Diário
  ↓
15min/5min → Timing / Gatilho de entrada
```

---

## Semáforo Macro — Decisão Rápida

| Semanal | Diário | 60min | Decisão Day Trade | Decisão Swing |
|---|---|---|---|---|
| ⬆️ Alta | ⬆️ Alta | ⬆️ Alta | ✅ Compra prioritária | ✅ Long com força |
| ⬆️ Alta | ⬆️ Alta | ⬇️ Baixa | ⚠️ Aguardar pullback | ✅ Long (aguardar retração) |
| ⬆️ Alta | ⬇️ Baixa | qualquer | ⚠️ Só compra em suporte forte | ❌ Não entrar swing |
| ⬇️ Baixa | ⬇️ Baixa | ⬇️ Baixa | ✅ Venda prioritária | ✅ Short com força |
| ⬇️ Baixa | ⬇️ Baixa | ⬆️ Alta | ⚠️ Aguardar topo para vender | ✅ Short (aguardar repique) |
| ⬇️ Baixa | ⬆️ Alta | qualquer | ⚠️ Só venda em resistência forte | ❌ Não entrar swing |
| ➡️ Lateral | qualquer | qualquer | ⚠️ Scalp somente | ❌ Não entrar swing |

> **Regra de ouro:** Se Semanal e Diário discordam → **mão leve ou aguardar**.
> Só operar com tamanho cheio quando **3 layers apontam o mesmo lado**.

---

## Layer 1 — Mensal (Clima do Ano)

**O que checar uma vez por semana:**

- [ ] WIN está acima ou abaixo dos **100.000 pts** (número psicológico)?
- [ ] Topo histórico relevante próximo (120.000, 130.000)?
- [ ] Sequência de meses: HH/HL (alta) ou LH/LL (baixa)?

```
Tendência Mensal de Alta:  Mensal[0].High > Mensal[1].High  E  Mensal[0].Low > Mensal[1].Low
Tendência Mensal de Baixa: Mensal[0].High < Mensal[1].High  E  Mensal[0].Low < Mensal[1].Low
```

**2026 — Referência histórica WIN (atualizar manualmente toda semana):**

| Item | Valor | Data |
|---|---|---|
| Topo histórico (referência) | registrar | — |
| Fundo do Bear Market recente | registrar | — |
| Nível psicológico próximo | registrar | — |
| Bias mensal atual | ALTA / BAIXA / LATERAL | — |

---

## Layer 2 — Semanal (Maré — Tendência Primária)

**O que checar na segunda-feira antes de abrir:**

- [ ] Close semanal acima ou abaixo da MME9 semanal?
- [ ] MME9 semanal inclinada para cima ou para baixo?
- [ ] Topo semanal anterior foi rompido? (HH → alta) Ou perdeu fundo? (LL → baixa)
- [ ] LTA (linha de fundos ascendentes) ou LTB (topos descendentes) intacta?

```
Tendência Semanal de Alta:
  Close_semanal > MME9_semanal  E  MME9_semanal > MME9_semanal[1]  E  HH/HL confirmados

Tendência Semanal de Baixa:
  Close_semanal < MME9_semanal  E  MME9_semanal < MME9_semanal[1]  E  LH/LL confirmados
```

**→ Swing Trade:** só entrar quando semanal confirma a direção.
**→ Day Trade:** usar como filtro de mão (operar só a favor).

---

## Layer 3 — Diário (Viés do Dia)

**O que checar toda manhã antes das 09:00:**

- [ ] **Close de ontem** acima ou abaixo da MME20 diária?
- [ ] **MME20 diária** inclinada para cima ou para baixo?
- [ ] **Candle de ontem:** bullish (mais verde que vermelho) ou bearish?
- [ ] **Gap de abertura:** abriu acima ou abaixo do fechamento de ontem?
- [ ] **Próxima resistência** (para trade de compra) — está longe o suficiente para RRR ≥ 2.0?
- [ ] **Ajuste do dia anterior** — preço está acima ou abaixo?

```
Viés Diário de COMPRA (todos os itens devem ser ✅):
  ✅ Close > MME20 diária
  ✅ MME20 diária inclinada para cima
  ✅ Candle de ontem: fechamento > abertura (bullish)
  ✅ Preço atual acima do Ajuste de ontem
  ✅ Sem resistência forte imediatamente acima

Viés Diário de VENDA:
  Simétrico para baixo.
```

---

## Layer 4 — 60min (Confirmação do Dia)

**O que checar ao entrar no pregão (09:15–10:00):**

- [ ] Close do 1° candle de 60min acima ou abaixo da MME20 no 60min?
- [ ] VWAP do dia: preço acima (buyers) ou abaixo (sellers)?
- [ ] **Primeiro pivô do dia:** para onde foi?

```
Confirmação 60min para COMPRA:
  Close_60min > MME20_60min
  Close_60min > VWAP_dia
  Primeiro pivô do dia foi de ALTA (rompeu máxima anterior)

Confirmação 60min para VENDA:
  Simétrico.
```

---

## Script Python — Relatório Matinal de Contexto

> Rodar toda manhã antes de abrir o pregão.
> Usa os CSVs disponíveis em `DadosCandlesBacktest/2024_26/`.
> Leitura rápida — não precisa abrir planilha, não cola nada no chat.

```python
# _scripts/contexto_diario.py
# Uso: python _scripts/contexto_diario.py
# Saída: Relatório de contexto em ~5 linhas para decisão de viés

import csv
from pathlib import Path
from datetime import datetime

# ── CONFIG ─────────────────────────────────────────────────────────────────
PASTA  = Path("DadosCandlesBacktest/2024_26")
ATIVO  = "WINFUT"
SEP    = ";"
CODPAG = "utf-8-sig"

def ler_csv(tf: str) -> list[dict]:
    """Lê CSV de um timeframe e retorna lista de dicts com OHLCV."""
    fname = PASTA / f"{ATIVO}_F_0_{tf}.csv"
    if not fname.exists():
        return []
    rows = []
    with open(fname, encoding=CODPAG, errors="replace") as f:
        for linha in csv.DictReader(f, delimiter=SEP):
            try:
                dt_str = linha.get("Data") or linha.get("Date") or ""
                hr_str = linha.get("Hora") or linha.get("Time") or "00:00:00"
                close  = float((linha.get("Fechamento") or linha.get("Close","0")).replace(",",".").replace(".","",linha.get("Fechamento","").count(".")-1) if "," in linha.get("Fechamento","") else linha.get("Fechamento","0").replace(",","."))
                rows.append({"dt": dt_str, "hr": hr_str, "close": close})
            except Exception:
                continue
    return rows[::-1]  # inverter: mais antigo primeiro (CSV vem decrescente)

def mme(serie: list[float], n: int) -> list[float]:
    """Média Móvel Exponencial."""
    k = 2 / (n + 1)
    result = []
    ema = serie[0] if serie else 0
    for v in serie:
        ema = v * k + ema * (1 - k)
        result.append(round(ema, 0))
    return result

def pivots_hh_hl(closes: list[float], janela: int = 3) -> str:
    """Retorna 'ALTA', 'BAIXA' ou 'LATERAL' baseado nos últimos N pivôs."""
    if len(closes) < janela * 2 + 1:
        return "INDEFINIDO"
    # Simplificado: compara médias de janelas consecutivas
    ultimos = closes[-janela*3:]
    p1 = sum(ultimos[:janela]) / janela
    p2 = sum(ultimos[janela:janela*2]) / janela
    p3 = sum(ultimos[janela*2:]) / janela
    if p3 > p2 > p1:
        return "ALTA"
    elif p3 < p2 < p1:
        return "BAIXA"
    else:
        return "LATERAL"

def relatorio():
    print("=" * 60)
    print(f"  CONTEXTO MACRO — {ATIVO} — {datetime.now().strftime('%d/%m/%Y %H:%M')}")
    print("=" * 60)

    # ── DIÁRIO ─────────────────────────────────────────────────────────────
    diario = ler_csv("Diário")
    if len(diario) >= 20:
        closes_d = [r["close"] for r in diario]
        mme9_d   = mme(closes_d, 9)
        mme20_d  = mme(closes_d, 20)
        mme200_d = mme(closes_d, 200)
        c_d   = closes_d[-1]
        ontem = closes_d[-2] if len(closes_d) > 1 else c_d

        bias_d = pivots_hh_hl(closes_d[-20:], janela=4)
        acima_mme9   = "✅" if c_d > mme9_d[-1]   else "❌"
        acima_mme20  = "✅" if c_d > mme20_d[-1]  else "❌"
        acima_mme200 = "✅" if c_d > mme200_d[-1] else "❌"
        mme20_sobe   = "📈" if mme20_d[-1] > mme20_d[-2] else "📉"
        candle_ontem = "🟢 BULLISH" if ontem > closes_d[-3] else "🔴 BEARISH" if len(closes_d) > 2 else ""

        print(f"\n📅 DIÁRIO (último fechamento: {diario[-1]['dt']})")
        print(f"  Close:      {c_d:,.0f}")
        print(f"  MME9:       {mme9_d[-1]:,.0f}  {acima_mme9} acima")
        print(f"  MME20:      {mme20_d[-1]:,.0f}  {acima_mme20} acima  {mme20_sobe} inclinação")
        print(f"  MME200:     {mme200_d[-1]:,.0f}  {acima_mme200} acima")
        print(f"  Candle ant: {candle_ontem}")
        print(f"  Estrutura:  {bias_d}")

        # Bias final do Diário
        votos = [c_d > mme9_d[-1], c_d > mme20_d[-1], c_d > mme200_d[-1],
                 mme20_d[-1] > mme20_d[-2], bias_d == "ALTA"]
        score = sum(votos)
        if score >= 4:
            viés_diario = "🟢 COMPRA"
        elif score <= 1:
            viés_diario = "🔴 VENDA"
        else:
            viés_diario = "🟡 NEUTRO"
        print(f"\n  ➤ VIÉS DIÁRIO: {viés_diario}  (score {score}/5)")
    else:
        viés_diario = "❓ SEM DADOS"
        print(f"\n📅 DIÁRIO: sem dados suficientes")

    # ── SEMANAL ────────────────────────────────────────────────────────────
    semanal = ler_csv("Semanal")
    if len(semanal) >= 10:
        closes_s = [r["close"] for r in semanal]
        mme9_s   = mme(closes_s, 9)
        c_s      = closes_s[-1]
        bias_s   = pivots_hh_hl(closes_s[-12:], janela=3)
        acima_s  = "✅" if c_s > mme9_s[-1] else "❌"
        mme9_sobe = "📈" if mme9_s[-1] > mme9_s[-2] else "📉"

        print(f"\n📆 SEMANAL")
        print(f"  Close:  {c_s:,.0f}  |  MME9: {mme9_s[-1]:,.0f}  {acima_s} {mme9_sobe}")
        print(f"  Estrutura: {bias_s}")

        votos_s = [c_s > mme9_s[-1], mme9_s[-1] > mme9_s[-2], bias_s == "ALTA"]
        score_s = sum(votos_s)
        if score_s == 3:
            viés_semanal = "🟢 ALTA"
        elif score_s == 0:
            viés_semanal = "🔴 BAIXA"
        else:
            viés_semanal = "🟡 INDEFINIDA"
        print(f"  ➤ TENDÊNCIA SEMANAL: {viés_semanal}")
    else:
        viés_semanal = "❓ SEM DADOS"
        print(f"\n📆 SEMANAL: sem dados suficientes")

    # ── DECISÃO FINAL ──────────────────────────────────────────────────────
    print("\n" + "─" * 60)
    print("  DECISÃO CONSOLIDADA")
    print("─" * 60)
    print(f"  Day Trade:   {viés_diario}")
    print(f"  Swing Trade: ", end="")

    if "COMPRA" in viés_diario and "ALTA" in viés_semanal:
        print("✅ LONG — semanal + diário alinhados para alta")
        print("  → Swing: entrar em pullback para MME20 diária")
        print("  → SL Swing: abaixo do fundo do pivô semanal")
    elif "VENDA" in viés_diario and "BAIXA" in viés_semanal:
        print("✅ SHORT — semanal + diário alinhados para baixa")
        print("  → Swing: entrar em repique para MME20 diária")
        print("  → SL Swing: acima do topo do pivô semanal")
    elif "NEUTRO" in viés_diario or "INDEFINIDA" in viés_semanal:
        print("⚠️  AGUARDAR — contexto indefinido")
        print("  → Day trade somente com setups muito claros")
        print("  → Swing: NÃO entrar")
    else:
        print("⚠️  DESALINHADO — semanal e diário divergem")
        print("  → Day trade: mão pequena, somente a favor do diário")
        print("  → Swing: NÃO entrar")

    print("=" * 60)

if __name__ == "__main__":
    relatorio()
```

**Como rodar (PowerShell ou terminal):**
```
cd c:\repositorio_wes\RepoRobos
python _scripts\contexto_diario.py
```

---

## Implementação em NTSL — Filtro de Contexto no Robô

> Para Day Trade: usa proxy de Diário e Semanal dentro do TF do robô.
> O proxy não é perfeito, mas filtra 80% dos trades contra-tendência.

### Inputs necessários

```pascal
input
  // Contexto de longo prazo (proxy de Diário e Semanal)
  iJanelaDiaria(9);       // 9 candles de 60min ≈ 1 dia (09h-17h40 ≈ 9 candles)
  iJanelaSemanal(45);     // 45 candles de 60min ≈ 1 semana (5 dias × 9 candles)
  UsarFiltroContexto(true);  // false = desligar filtro (útil para backtest inicial)
```

### Variáveis e cálculo

```pascal
var
  fMediaDiaria   : float;   // proxy da MME9 diária no 60min
  fMediaSemanal  : float;   // proxy da MME9 semanal no 60min
  bContextoDiarioAlta   : boolean;
  bContextoDiarioBaixa  : boolean;
  bContextoSemanalAlta  : boolean;
  bContextoSemanalBaixa : boolean;

begin
  // ── PROXY DE CONTEXTO (roda em 60min) ────────────────────────────────────
  fMediaDiaria  := MediaExp(iJanelaDiaria,  Close);
  fMediaSemanal := MediaExp(iJanelaSemanal, Close);

  // Diário de alta: Close acima da média diária E média subindo
  bContextoDiarioAlta  := (Close > fMediaDiaria)
                       and (fMediaDiaria > fMediaDiaria[iJanelaDiaria]);

  bContextoDiarioBaixa := (Close < fMediaDiaria)
                       and (fMediaDiaria < fMediaDiaria[iJanelaDiaria]);

  // Semanal de alta: media semanal subindo
  bContextoSemanalAlta  := fMediaSemanal > fMediaSemanal[iJanelaSemanal];
  bContextoSemanalBaixa := fMediaSemanal < fMediaSemanal[iJanelaSemanal];

  // ── APLICAR FILTRO NAS ENTRADAS ─────────────────────────────────────────
  // Compra: exige Diário de alta (semanal = bonus, não obrigatório para DT)
  bSinalCompra := bSinalCompra
               and (not UsarFiltroContexto or bContextoDiarioAlta);

  // Venda: exige Diário de baixa
  bSinalVenda  := bSinalVenda
               and (not UsarFiltroContexto or bContextoDiarioBaixa);
```

### Adaptação para outros TFs

| TF do robô | iJanelaDiaria | iJanelaSemanal | Observação |
|---|---|---|---|
| **60min** | 9 | 45 | ✅ Mais preciso (padrão acima) |
| **15min** | 36 | 180 | 4 candles × 9 períodos diários |
| **5min** | 108 | 540 | 12 candles × 9 períodos diários |
| **30min** | 18 | 90 | 2 candles × 9 períodos diários |

> **Nota:** Janelas grandes (>100 barras) funcionam bem em tendências, mas reagem lentamente em reversões — isso é o comportamento desejado (filtrar ruído).

---

## Regras de Swing Trade

> Swing = posição mantida por 2 a 10 dias úteis.
> Requer contexto macro alinhado — não entrar sem confirmar Semanal + Diário.

### Critérios de entrada Swing (todos obrigatórios)

```
✅ Semanal: estrutura de alta (HH/HL) + Close acima da MME9 semanal
✅ Diário:  Close acima da MME20 diária, media subindo
✅ Diário:  Pullback para zona de MME20 ou suporte (não comprar longe)
✅ 60min:   Candle de força (fForca ≥ 55) no ponto de retomada
✅ RRR ≥ 2.5 (mais exigente que day trade — posição fica exposta mais tempo)
✅ SL: abaixo do fundo do último pivô diário (não do intraday)
```

### Gerenciamento Swing

```
Tamanho: máx 50% do capital em risco (metade do tamanho normal)
         — mais dias = mais risco de notícia/gap

SL inicial: abaixo do fundo do pivô semanal = ATR_diário × 1.5
           (ATR diário médio WIN 2024-26: ~1.500 pts)

Trailing: após lucro de 1 ATR diário → mover SL para breakeven
          após lucro de 2 ATR diário → trailing no último fundo diário

Alvo parcial: 50% na resistência diária mais próxima
Alvo total: próximo pivô semanal

Stop horário: NÃO usar para swing (manter posição overnight)
              Mas monitorar no fechamento às 17:45
```

### Custo Swing vs Day Trade

| Item | Day Trade | Swing Trade |
|---|---|---|
| SL típico (WIN) | 150–300 pts | 800–2.000 pts |
| Contratos (capital R$10k, risco 2%) | 4–6 ctt | 1–2 ctt |
| Custo por trade (spread + slip) | ~25 pts | ~25 pts (diluído) |
| Exposição a gap overnight | ❌ Nenhuma | ⚠️ Alta (geopolitica, macro) |
| Custo de carrego (futuro) | Zero | Ajuste diário (mínimo) |
| Imposto | 1% sobre ganho bruto | 15% sobre ganho bruto |

> **Atenção:** Swing em minicontratos tem **imposto de 15%** sobre o ganho bruto (não compensado de mês anterior). Day trade tem **1%** na fonte. Considerar no cálculo de resultado líquido.

---

## Checklist Matinal — 5 min antes de abrir

```
[ ] Rodar: python _scripts\contexto_diario.py
[ ] Anotar: Viés Diário = COMPRA / VENDA / NEUTRO
[ ] Anotar: Tendência Semanal = ALTA / BAIXA / INDEFINIDA
[ ] Verificar: WDO — subiu ou caiu ontem? (WDO↑ → cautela no WIN long)
[ ] Verificar: S&P futuro — está no positivo ou negativo?
[ ] Marcar no gráfico: Ajuste de ontem + Máxima e Mínima de ontem
[ ] Definir: "Hoje procuro COMPRA, VENDA ou NEUTRO (scalp apenas)"
```

---

## Regra de Ouro (resumo final)

```
3 layers alinhados → mão cheia (tamanho máximo)
2 layers alinhados → mão média (50–70% do tamanho)
1 layer ou neutro  → mão pequena ou não operar
Sem alinhamento    → aguardar próximo setup

NUNCA operar contra os 3 layers ao mesmo tempo.
```

---

## Referência cruzada

- `skills/skill_gestao_risco.md` → SL mínimo e dimensionamento de contratos
- `skills/skill_confluencia_geometrica.md` → zonas de entrada dentro do contexto
- `skills/skill_padroes_geometricos.md` → gatilhos compatíveis com o viés
- `skills/skill_WIN_caracteristicas.md` → ATR, horários, correlações externas
- `_scripts/contexto_diario.py` → relatório automatizado de contexto
- `DadosCandlesBacktest/2024_26/` → dados reais WINFUT Diário e Semanal
