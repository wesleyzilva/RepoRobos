# Grupo SCALPING (SC)

## Por que é Obrigatório Conhecer
Scalping é a arte de capturar movimentos rápidos e pequenos (5–30 pts no WIN) com alta frequência. É a base do day trade moderno e define se você consegue "sentir" o fluxo do mercado no menor timeframe.

Sem entender scalping, você não entende:
- O comportamento do tape (fluxo de ordens)
- A liquidez mínima para entrar/sair sem slippage
- Por que às vezes o mercado anda rápido demais para ordens a mercado

---

## Filosofia

| Característica | Valor |
|----------------|-------|
| Timeframe | 1min / 2min |
| Alvo por operação | 10–30 pts |
| Stop máximo | 20–40 pts |
| R:R mínimo | 1:1 (a frequência compensa) |
| Operações/dia | 5–15 |
| Taxa de acerto meta | > 60% |
| Filtro obrigatório | Horário de liquidez (09:05–10:30, 14:00–16:00) |

---

## Indicadores Mais Usados em Scalping

| Indicador | Aplicação |
|-----------|-----------|
| **IFR(2) ou IFR(3)** | Extremos rápidos em timeframe curto |
| **MME9** | Direção local (scalp na direção da MME9) |
| **Estocástico(5,3)** | Reversão rápida (cruzamento nas zonas) |
| **VWAP** | Âncora — scalp entre preço e VWAP |
| **Volume por Barra** | Evitar barras de baixo volume |
| **Tape/Fluxo (manual)** | Leitura da ordem de fluxo (nível avançado) |

---

## Estrutura dos Robôs SC

```
SC_01 — IFR(3) extremo + MME9 + alvo 15 pts fixo              (Profit .ntsl)
SC_02 — VWAP distance + reversão + saída na VWAP              (Profit .ntsl)
SC_03 — Estocástico crossover 1min + alvo 20 pts              (Profit .ntsl)
SC_04 — MT5: IFR(3) scalp XAUUSD / NAS100                     (MQL5 .mq5)
```

## Estrutura de Pastas
```
SCALPING/
├── scalping.md          ← este arquivo
├── codigo_fonte/        ← robôs Profit (.ntsl.txt)
└── mql5/                ← robôs MetaTrader (.mq5)
```
