# Laboratório de Indicadores — LABORATORIO_INDICADORES

> Status: **Estrutura criada — robôs pendentes**
> Objetivo: testar cada indicador isoladamente e em combinação antes de integrar aos grupos principais

---

## Por que um laboratório separado?

Os grupos principais (`CANDLE1`, `IFR_RSI`, etc.) já têm hipóteses definidas.
O laboratório serve para **validar um indicador antes de incluí-lo** — sem contaminar os resultados dos grupos com código experimental.

Fluxo correto:
```
LABORATORIO → backtest isolado → aprovado? → integrar em grupo principal
                                → reprovado? → documentar motivo e arquivar
```

---

## Prioridade de Teste

### Nível 1 — Alto valor, testar primeiro

| Indicador | Pasta | Parâmetro padrão | Hipótese a validar |
|-----------|-------|-----------------|-------------------|
| **ADX** | `ADX/` | 14 períodos | ADX > 25 melhora taxa de acerto do IFR? |
| **Estocástico** | `ESTOCASTICO/` | (5,3) e (14,3) | Mais rápido que IFR para saída? |
| **Bollinger Bands** | `BOLLINGER/` | (20, 2σ) | Toque na banda + IFR = confluência? |
| **OBV** | `OBV/` | — | Divergência OBV filtra fakeouts? |

### Nível 2 — Combinações (testar após validar os individuais)

| Combo | Pasta | Hipótese |
|-------|-------|---------|
| **IFR + ADX** | `COMBOS/IFR_ADX/` | ADX > 25 elimina stops falsos do IFR em tendência? |
| **Bollinger + IFR** | `COMBOS/BOLLINGER_IFR/` | Banda externa + IFR extremo = reversão de alta probabilidade? |
| **VWAP + Volume** | `COMBOS/VWAP_VOLUME/` | Pullback na VWAP com volume elevado = entrada institucional? |
| **ATR + MME200** | `COMBOS/ATR_MME200/` | Stop em ATR × 1.5 além da MME200 = stop estrutural eficiente? |

### Nível 3 — Avançados (testar quando tiver base sólida)

| Indicador | Pasta | Por que esperar |
|-----------|-------|----------------|
| **Parabolic SAR** | `AVANCADOS/PARABOLIC_SAR/` | Trailing excelente mas precisa entender o viés antes |
| **MACD (12,26,9)** | `AVANCADOS/MACD/` | Bom para confirmar momentum, mas lag alto em 1-5min |
| **Keltner Channel** | `AVANCADOS/KELTNER/` | Alternativa à Bollinger — menos fakeouts |
| **Williams %R** | `AVANCADOS/WILLIAMS_R/` | Mais sensível que Estocástico — útil para saída rápida |

---

## Estrutura de Pastas

```
LABORATORIO_INDICADORES/
│
├── README.md              ← este arquivo
│
├── ADX/
│   ├── ntsl/              ← robôs Profit isolando só o ADX (.ntsl)
│   └── mql5/              ← versão MT5 (.mq5)
│
├── ESTOCASTICO/
│   ├── ntsl/
│   └── mql5/
│
├── BOLLINGER/
│   ├── ntsl/
│   └── mql5/
│
├── OBV/
│   ├── ntsl/
│   └── mql5/
│
├── COMBOS/
│   ├── IFR_ADX/
│   │   └── ntsl/
│   ├── BOLLINGER_IFR/
│   │   └── ntsl/
│   ├── VWAP_VOLUME/
│   │   └── ntsl/
│   └── ATR_MME200/
│       └── ntsl/
│
└── AVANCADOS/
    ├── PARABOLIC_SAR/
    │   └── ntsl/
    ├── MACD/
    │   └── ntsl/
    ├── KELTNER/
    │   └── ntsl/
    └── WILLIAMS_R/
        └── ntsl/
```

---

## Critério Mínimo para Aprovação (por indicador)

| Métrica | Aprovado se... |
|---------|---------------|
| Melhora taxa de acerto | + 3 pp em relação à versão sem o indicador |
| Não piora drawdown | Drawdown ≤ versão base |
| Robustez | Funciona em ao menos 3 timeframes diferentes |
| Simplicidade | Máximo 1 parâmetro adicional |

---

## Regra de Ouro

```
1 indicador de TENDÊNCIA  (MME200, ADX)
+ 1 indicador de MOMENTO  (IFR, Estocástico, MACD)
+ 1 indicador de VOLUME   (OBV, Volume relativo, VWAP)
─────────────────────────────────────────────────────
= 3 camadas → alta confluência sem overfitting
```

> Mais de 3 indicadores = risco de overfitting.
> O robô passa no backtest mas falha ao vivo porque "memorizou" o passado.
