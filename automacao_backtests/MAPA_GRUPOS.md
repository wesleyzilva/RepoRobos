# Mapa de Grupos de Robôs — RepoRobos

> Última atualização: março/2026
> Branch ativa: `marco_Tradeoperador`
> Capital Profit: R$10.000 | Capital MT5: USD$5.000

---

## Convenção de Arquivos

| Extensão | Plataforma | Mercado |
|----------|-----------|---------|
| `.ntsl.txt` | **Neologica Profit** | B3 — WIN (minicontrato de índice) |
| `.mq5` | **MetaTrader 5** | Internacional — XAUUSD, NAS100, US30, EURUSD |

Cada grupo possui:
```
GRUPO/
├── grupo.md           → Documentação, filosofia, critérios
├── codigo_fonte/      → Robôs Profit (.ntsl.txt)
└── mql5/              → Robôs MetaTrader (.mq5)
```

---

## Grupos Ativos (13 no total)

### Grupos Já Desenvolvidos

| Grupo | Pasta | Robôs NTSL | Robôs MQL5 | Status |
|-------|-------|------------|------------|--------|
| Primeiro Candle | `CANDLE1/` | 33 (PC_01–PC_33) | — | ✅ Completo |
| IFR/RSI | `IFR_RSI/` | 3 feitos / 14 planejados | — | 🔄 Em progresso |
| Médias | `MEDIAS/` | 0 / 18 planejados | — | ⬜ Pendente |
| Stop Tolerante | `STOPTOLERANTE/` | 4 (ST_01–ST_04) | — | ✅ Completo |
| Poucos Pontos Vencedores | `POUCOSPONTOSVENCEDORES/` | 4 (PPV_01–PPV_04) | — | 🔄 Faltam 05–08 |
| Drawdown Zero | `DRAWDOWNZERO/` | 0 / 4 planejados | — | ⬜ Pendente |
| 50Mais1 | `50mais1/` | 0 / 4 planejados | — | ⬜ Pendente |

### Grupos Obrigatórios — Pasta Criada, Robôs Pendentes

| Grupo | Pasta | Conceito Central | Prioridade |
|-------|-------|-----------------|------------|
| Scalping | `SCALPING/` | Capturar 10–30 pts, alta frequência, 1–2min | Alta |
| Breakout | `BREAKOUT/` | Rompimento de range/nível com volume | Alta |
| VWAP Institucional | `VWAP_INSTITUCIONAL/` | Operar com referência do fluxo institucional | Alta |
| Tendência Seguir | `TENDENCIA_SEGUIR/` | Trend following puro — sem alvo, trailing ATR | Média |
| Reversão à Média | `REVERSAO_MEDIA/` | Bollinger/VWAP extremo → retorno à média | Média |
| Horário Específico | `HORARIO_ESPECIFICO/` | Janelas estatísticas do WIN + sessões MT5 | Alta |

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
│   ├── codigo_fonte/   → 33 robôs (mar_PC_01 a mar_PC_33) ✅
│   └── mql5/           → (pendente)
│
├── IFR_RSI/
│   ├── codigo_fonte/   → 3 robôs (mar_IFR_01-03) + 10 antigos 🔄
│   └── mql5/           → (pendente)
│
├── MEDIAS/
│   ├── codigo_fonte/   → (pendente)
│   └── mql5/           → (pendente)
│
├── POUCOSPONTOSVENCEDORES/
│   ├── codigo_fonte/   → 4 robôs (mar_PPV_01-04) 🔄
│   └── mql5/           → (pendente)
│
├── STOPTOLERANTE/
│   ├── codigo_fonte/   → 4 robôs (mar_ST_01-04) ✅
│   └── mql5/           → (pendente)
│
├── DRAWDOWNZERO/
│   ├── codigo_fonte/   → (pendente)
│   └── mql5/           → (pendente)
│
├── 50mais1/
│   ├── codigo_fonte/   → (pendente)
│   └── mql5/           → (pendente)
│
├── SCALPING/           ← NOVO
│   ├── codigo_fonte/   → (pendente)
│   └── mql5/           → (pendente)
│
├── BREAKOUT/           ← NOVO
│   ├── codigo_fonte/   → (pendente)
│   └── mql5/           → (pendente)
│
├── VWAP_INSTITUCIONAL/ ← NOVO
│   ├── codigo_fonte/   → (pendente)
│   └── mql5/           → (pendente)
│
├── TENDENCIA_SEGUIR/   ← NOVO
│   ├── codigo_fonte/   → (pendente)
│   └── mql5/           → (pendente)
│
├── REVERSAO_MEDIA/     ← NOVO
│   ├── codigo_fonte/   → (pendente)
│   └── mql5/           → (pendente)
│
└── HORARIO_ESPECIFICO/ ← NOVO
    ├── codigo_fonte/   → (pendente)
    └── mql5/           → (pendente)

LABORATORIO_INDICADORES/ ← NOVO
├── ADX/
├── ESTOCASTICO/
├── BOLLINGER/
├── OBV/
├── COMBOS/
│   ├── IFR_ADX/
│   ├── BOLLINGER_IFR/
│   ├── VWAP_VOLUME/
│   └── ATR_MME200/
└── AVANCADOS/
    ├── PARABOLIC_SAR/
    ├── MACD/
    ├── KELTNER/
    └── WILLIAMS_R/
```

---

## Backlog de Robôs Pendentes (ordenado por prioridade)

### Imediato
- [ ] PPV_05 a PPV_08 (`POUCOSPONTOSVENCEDORES`)
- [ ] IFR_04 a IFR_14 (`IFR_RSI`)
- [ ] DZ_01 a DZ_04 (`DRAWDOWNZERO`)
- [ ] WR_01 a WR_04 (`50mais1`)

### Próximo Ciclo
- [ ] MEDIAS_01 a MEDIAS_18
- [ ] SC_01 a SC_04 (`SCALPING`)
- [ ] BK_01 a BK_04 (`BREAKOUT`)
- [ ] VI_01 a VI_04 (`VWAP_INSTITUCIONAL`)
- [ ] TS_01 a TS_04 (`TENDENCIA_SEGUIR`)
- [ ] RM_01 a RM_04 (`REVERSAO_MEDIA`)
- [ ] HE_01 a HE_04 (`HORARIO_ESPECIFICO`)
- [ ] Versões MQL5 dos principais grupos

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
UsarGestaoRisco      = true
UsarHardLock         = true
SaldoConta           = 10000.0    // R$10.000
RiscoDiaPct          = 1.5        // R$150/dia
RiscoSemanaPct       = 3.0        // R$300/semana
MaxStopsConsecutivos = 2          // (1 para DRAWDOWNZERO)
ValorPorPonto        = 0.2        // 1 contrato WIN mini
DiaSemanaReset       = 2          // segunda-feira
```

```mql5
// MetaTrader 5 (MQL5)
VolumeLote          = 0.01        // USD$5.000 demo Tickmill
RiscoPorOpPct       = 1.5
MaxStopsConsec      = 2
MagicNumber         = 2026XX     // último 2 dígitos = número do robô
```
