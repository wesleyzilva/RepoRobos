# Mapa de Grupos de Robôs — RepoRobos

> Última atualização: março/2026
> Branch ativa: `marco_Tradeoperador`
> Capital Profit: R$10.000 | Capital MT5: USD$5.000

---

## Convenção de Arquivos

| Extensão | Plataforma | Uso |
|----------|-----------|-----|
| `.ntsl` | **Neologica Profit** | B3 — WIN (minicontrato de índice) |
| `.mq5` | **MetaTrader 5** | Internacional — XAUUSD, NAS100, US30, EURUSD |
| `.csv` | Resultados | Saída dos backtests com timeframe no final |
| `.txt` | Anotações | Exclusivamente texto livre / rascunhos |

**Nomenclatura:** `mar_GRUPO_NN_descricao_timeframe.ntsl` (sem número de versão `vX`)

Cada grupo possui:
```
GRUPO/
├── GRUPO.md                  → Documentação, filosofia, critérios
├── ntsl/                     → Robôs Profit (.ntsl)
├── mql5/                     → Robôs MetaTrader (.mq5)
├── resultsBackTestTimeframe/ → Resultados CSV por timeframe
└── reprovados/               → Versões descartadas
```

---

### Grupos Ativos (18 no total)

| Grupo | Pasta | NTSL | MQL5 | Status |
|-------|-------|------|------|--------|
| Primeiro Candle | `CANDLE1/` | 33 | — | ✅ Completo |
| IFR/RSI | `IFR_RSI/` | 10+ legado | — | 📦 Referência |
| Médias | `MEDIAS/` | 6 | — | ✅ Completo |
| Stop Tolerante | `STOPTOLERANTE/` | 5 | — | ✅ Completo |
| Poucos Pontos Vencedores | `POUCOSPONTOSVENCEDORES/` | 5 | — | ✅ Completo |
| Drawdown Zero | `DRAWDOWNZERO/` | 5 | — | ✅ Completo |
| 50Mais1 | `50mais1/` | 5 | — | ✅ Completo |
| Dupla Confirmação | `DUPLACONFIRMAÇÃO/` | 5 | — | ✅ Completo |
| Scalping | `SCALPING/` | 5 | — | ✅ Completo |
| Breakout | `BREAKOUT/` | 5 | — | ✅ Completo |
| VWAP Institucional | `VWAP_INSTITUCIONAL/` | 5 | — | ✅ Completo |
| Tendência Seguir | `TENDENCIA_SEGUIR/` | 5 | — | ✅ Completo |
| Reversão Média | `REVERSAO_MEDIA/` | 5 | 5 | ✅ Completo |
| Horário Específico | `HORARIO_ESPECIFICO/` | 5 | — | ✅ Completo |
| Laboratório Indicadores | `LABORATORIO_INDICADORES/` | 5 | — | ✅ Completo |
| Lateralização DayTrade | `LATERALIZACAO_DAYTRADE/` | 5 | — | ✅ Completo |
| Lateralização SwingTrade | `LATERALIZACAO_SWINGTRADE/` | 5 | — | ✅ Completo |
| timeframeMenor | `timeframeMenor/` | 5 | — | ✅ Completo |

---

## Por que Esses 6 Grupos São Obrigatórios

```
SCALPING          → Entender o tick a tick. Base de tudo.
BREAKOUT          → Rompimentos com volume são as melhores R:R do WIN
VWAP_INSTITUCIONAL → Sem VWAP você não vê onde o dinheiro grande está
TENDENCIA_SEGUIR  → Aprender a "sentar no trade" e deixar rodar
REVERSAO_MEDIA    → WIN é cíclico — reversão funciona em 60% do tempo
HORARIO_ESPECIFICO → Horário define liquidez, slippage e probabilidade
```

---

## Árvore Completa de Pastas

```
automacao_backtests/
│
├── CANDLE1/
│   ├── ntsl/         → 33 robôs (mar_PC_01 a mar_PC_33) ✅
│   └── mql5/         → (pendente)
│
├── IFR_RSI/
│   ├── legado/       → robôs antigos (robo_ifr_v*) — só referência
│   └── mql5/         → (pendente)
│
├── MEDIAS/
│   └── ntsl/         → 6 robôs ✅
│
├── POUCOSPONTOSVENCEDORES/
│   └── ntsl/         → 5 robôs ✅
│
├── STOPTOLERANTE/
│   └── ntsl/         → 5 robôs ✅
│
├── DRAWDOWNZERO/
│   └── ntsl/         → 5 robôs ✅
│
├── 50mais1/
│   └── ntsl/         → 5 robôs ✅
│
├── DUPLACONFIRMAÇÃO/
│   └── ntsl/         → 5 robôs ✅
│
├── SCALPING/
│   └── ntsl/         → 5 robôs ✅
│
├── BREAKOUT/
│   └── ntsl/         → 5 robôs ✅
│
├── VWAP_INSTITUCIONAL/
│   └── ntsl/         → 5 robôs ✅
│
├── TENDENCIA_SEGUIR/
│   └── ntsl/         → 5 robôs ✅
│
├── REVERSAO_MEDIA/
│   ├── ntsl/         → 5 robôs ✅
│   └── mql5/         → 5 robôs ✅
│
├── HORARIO_ESPECIFICO/
│   └── ntsl/         → 5 robôs ✅
│
├── LABORATORIO_INDICADORES/
│   └── ntsl/         → 5 robôs ✅
│
├── LATERALIZACAO_DAYTRADE/
│   └── ntsl/         → 5 robôs ✅
│
├── LATERALIZACAO_SWINGTRADE/
│   └── ntsl/         → 5 robôs ✅
│
└── timeframeMenor/
    └── ntsl/         → 5 robôs ✅
```

---

## Backlog de Robôs Pendentes (MQL5)

- [ ] MQL5 para todos os grupos (prioridade: grupos com mais de 60% de acerto validado)
- [ ] Backtest CSV por timeframe para todos os grupos aprovados

---

## Laboratório de Indicadores

> Pasta: `LABORATORIO_INDICADORES/`
> Propósito: validar indicadores isoladamente antes de integrar nos grupos principais

### Fluxo
```
Laboratório → backtest isolado → aprovado (+3pp acerto, drawdown ok) → integrar grupo
                               → reprovado → documentar e arquivar
```

### Fila de Testes (ordem de prioridade)

| # | Indicador/Combo | Pasta | Hipótese | Status |
|---|----------------|-------|---------|--------|
| 1 | **ADX(14)** | `ADX/` | ADX > 25 elimina stops falsos do IFR em tendência | ⬜ Pendente |
| 2 | **Estocástico(5,3)** | `ESTOCASTICO/` | Mais rápido que IFR para saída e scalping | ⬜ Pendente |
| 3 | **Bollinger(20,2σ)** | `BOLLINGER/` | Toque na banda + IFR extremo = alta confluência | ⬜ Pendente |
| 4 | **OBV** | `OBV/` | Divergência OBV filtra fakeouts antes da entrada | ⬜ Pendente |
| 5 | **IFR + ADX** | `COMBOS/IFR_ADX/` | ADX filtra os falsos do IFR sozinho | ⬜ Pendente |
| 6 | **Bollinger + IFR** | `COMBOS/BOLLINGER_IFR/` | Confluência banda+IFR = reversão de alta prob. | ⬜ Pendente |
| 7 | **VWAP + Volume** | `COMBOS/VWAP_VOLUME/` | Volume elevado na VWAP = entrada institucional | ⬜ Pendente |
| 8 | **ATR + MME200** | `COMBOS/ATR_MME200/` | Stop ATR×1.5 além da MME200 = stop estrutural | ⬜ Pendente |
| 9 | Parabolic SAR | `AVANCADOS/PARABOLIC_SAR/` | Trailing dinâmico superior ao ATR fixo | ⬜ Futuro |
| 10 | MACD(12,26,9) | `AVANCADOS/MACD/` | Confirma momentum — evita entrar no fim do movimento | ⬜ Futuro |
| 11 | Keltner Channel | `AVANCADOS/KELTNER/` | Menos fakeouts que Bollinger | ⬜ Futuro |
| 12 | Williams %R | `AVANCADOS/WILLIAMS_R/` | Saída mais rápida que Estocástico | ⬜ Futuro |

---

## Parâmetros Padrão de Gestão de Risco (todos os grupos)

```ntsl
// Profit (NTSL)
input UsarGestaoRisco      = true;   // false = backtest puro
input UsarHardLock         = true;   // false = só bloqueia entradas
input SaldoConta           = 10000.0;
input RiscoDiaPct          = 1.5;    // R$150/dia
input RiscoSemanaPct       = 3.0;    // R$300/semana
input MaxStopsConsecutivos = 2;
input ValorPorPonto        = 0.2;    // 1 contrato WIN mini
input DiaSemanaReset       = 2;      // 2 = segunda-feira
```

```mql5
// MetaTrader 5 (MQL5 / Internacional)
input bool   UsarGestaoRisco      = true;
input bool   UsarHardLock         = true;
input double SaldoConta           = 10000.0;
input double RiscoDiaPct          = 1.5;
input double RiscoSemanaPct       = 3.0;
input int    MaxStopsConsecutivos = 2;
input double ValorPorPonto        = 0.20;   // WIN=0.20, XAUUSD=1.0 etc.
input int    DiaSemanaReset       = 1;      // 0=Dom 1=Seg (MT5: 0-based)
input double LotePadrao           = 1.0;
```
