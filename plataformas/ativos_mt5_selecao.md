# Ativos para MT5 — Seleção e Justificativa

> Critério de seleção: compatibilidade com as estratégias desenvolvidas
> (primeiro candle, IFR, PPV trailing, médias), liquidez adequada e acesso via Tickmill demo.

---

## Os 5 Ativos Escolhidos

| # | Símbolo MT5 | Ativo | Grupo compatível | Sessão principal (BRT) |
|---|-------------|-------|-----------------|----------------------|
| 1 | `US30` | Dow Jones Industrial | CANDLE1, PPV, IFR | 10h30–17h (horário de verão EUA) |
| 2 | `XAUUSD` | Ouro (Gold) | PPV, IFR, MEDIAS | 09h–18h (Londres + NY) |
| 3 | `NAS100` | Nasdaq 100 | CANDLE1, PPV, MEDIAS | 10h30–17h |
| 4 | `EURUSD` | Euro/Dólar | IFR, MEDIAS | 09h–12h (Londres) |
| 5 | `US500` | S&P 500 | CANDLE1, IFR, PPV | 10h30–17h |

---

## Por que Cada Ativo

### 1. US30 — Dow Jones (`US30`)
**Mais similar ao WIN em comportamento.**
- Opens forte às 09:30 EST com gap frequente → ideal para estratégias CANDLE1
- Movimentos de 100-400 pontos equivalentes na abertura
- Alta liquidez, spread baixo na Tickmill (~2-3 pts)
- Responde bem a IFR em sobrevenda/sobrecompra nos extremos do dia
- **Recomendado para testar primeiro** — lógica mais próxima dos PC_XX

### 2. XAUUSD — Ouro
**Melhor ativo para estratégias PPV (pegar pontos sem devolver).**
- Volatilidade alta e previsível: 15-30 pts por candle em 15min
- IFR funciona muito bem no Ouro (reversões respeitam extremos)
- Sessão de Londres (09h-12h BRT) ideal: movimento direcional forte
- ATR trailing funciona excelente — Ouro não volta abrupto em tendências
- **Melhor para PPV_01 e PPV_02** (alvo ATR + be agressivo)

### 3. NAS100 — Nasdaq 100
**Melhor momentum e força nos candles de abertura.**
- Tecnologia domina → candles de força clara (corpo > 70%) na abertura
- Setup de gap externo com corpo forte (equivalente PC_01/PC_02) funciona bem
- Mais volátil que US500 → alvos maiores, stops farther
- MME200 funciona como filtro de tendência de longo prazo (bull market tech)
- **Melhor para CANDLE1 e MEDIAS com MME200**

### 4. EURUSD — Euro/Dólar
**Ideal para estratégias IFR e de médias moveis.**
- Mercado Forex 24h → IFR funciona em range estruturado
- Spreads ultra baixos na Tickmill (~0.1 pip) → menos impacto nos resultados
- Médias MME9/20/50/200 respeitadas claramente pela estrutura
- Sessão 09h-12h BRT (abertura Londres) = melhor janela para IFR_RSI
- **Melhor para IFR_01, IFR_02, IFR_03 e estratégias MEDIAS**

### 5. US500 — S&P 500
**Diversificação e benchmark do mercado americano.**
- Índice amplo → menos volátil que NAS100, mais estável que US30
- Excelente para testar robustez das estratégias (mais "médio" do mercado)
- Combinação CANDLE1 + IFR funciona com taxa de acerto consistente
- PPV com alvo fixo 80-100 pts funciona bem no US500
- **Melhor para validar robustez antes de aplicar nos outros**

---

## Horários de Operação por Ativo (Horário Brasília)

```
                  06h   07h   08h   09h   10h   11h   12h   13h   14h   15h   16h   17h   18h
XAUUSD (Ouro)     ──────────────────[===LONDRES===]========[========NY========]──────────────
EURUSD (Forex)    ──────────────────[===LONDRES===]────────────────────────────────────────
US30/NAS100/US500 ─────────────────────────────────────────[==========NY==========]─────────
```

**Janelas recomendadas para operar:**
| Ativo | Melhor janela | Por quê |
|-------|--------------|---------|
| US30, NAS100, US500 | 10h30–12h (BRT) | 1º candle de abertura NY |
| XAUUSD | 09h–11h (BRT) | Abertura Londres + pré-NY |
| EURUSD | 09h–11h (BRT) | Volatilidade máxima Londres |

---

## Correspondência com os Grupos de Robôs

| Grupo | Melhor ativo | 2º melhor |
|-------|-------------|-----------|
| CANDLE1 (PC_XX) | US30 | NAS100 |
| IFR_RSI | EURUSD | XAUUSD |
| PPV (PPV_XX) | XAUUSD | US30 |
| MEDIAS | NAS100 | EURUSD |
| POUCOSPONTOSVENCEDORES | XAUUSD | US500 |

---

## Parâmetros Mínimos por Ativo (Tickmill, 1 lote mínimo = 0.01)

| Ativo | Valor por pip/pt (0.01 lote) | Stop sugerido | Alvo sugerido |
|-------|------------------------------|---------------|---------------|
| US30 | ~$0.01/pt | 40-80 pts | 80-150 pts |
| XAUUSD | ~$0.01/pip | 60-100 pips | 80-150 pips |
| NAS100 | ~$0.01/pt | 50-100 pts | 100-200 pts |
| EURUSD | ~$0.10/pip | 20-40 pips | 30-60 pips |
| US500 | ~$0.01/pt | 30-60 pts | 60-100 pts |

> Com **USD 5.000** na conta demo, operar sempre com **0.01 lote** (tamanho mínimo)
> para ter resultado realista sem risco de margem.

---

## Arquivo de Teste

Para rodar o primeiro backtest, use o EA de exemplo:
`plataformas/mql5/mar_MT5_PPV01_exemplo.mq5`

**Configuração sugerida para o primeiro backtest:**
```
Ativo:      XAUUSD
Timeframe:  M15
Capital:    5000 USD
Lote:       0.01
Período:    01.01.2022 a 07.03.2026
Modelo:     1 minute OHLC (rápido para validar configuração)
```
