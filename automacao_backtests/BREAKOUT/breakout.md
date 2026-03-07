# Grupo BREAKOUT (BK)

## Por que é Obrigatório Conhecer
Breakout (rompimento) é um dos setups mais clássicos e confiáveis do mercado. Quando o preço rompe um nível importante — máxima do dia anterior, topo de um range, resistência histórica — ele tende a se mover com força na direção do rompimento.

No WIN, os rompimentos de abertura e da máxima/mínima da primeira hora são eventos de alta liquidez que institucionais usam ativamente.

---

## Tipos de Breakout no WIN

| Tipo | Descrição | Momento |
|------|-----------|---------|
| **Abertura** | Preço rompe máx/mín do 1º candle de 5min | 09:10–09:30 |
| **Dia anterior** | Rompe máx/mín de D-1 | Qualquer hora |
| **Range de consolidação** | Rompimento de LTB/LTA | Após 30+ min de lateral |
| **VWAP breakout** | Cruza e fica acima/abaixo da VWAP | Alta liquidez |
| **Bollinger squeeze** | Compressa + expansão explosiva | Antes de notícias ou abertura |

---

## Filosofia

| Característica | Valor |
|----------------|-------|
| Timeframe | 5min / 15min / 30min |
| Alvo | 1x–2x o tamanho do range anterior |
| Stop | Abaixo/acima do nível rompido |
| Filtro obrigatório | **Volume confirmando** + fechamento do candle acima do nível |
| Erro clássico | Entrar antes do fechamento (fakeout) |

---

## Indicadores Utilizados

| Indicador | Função |
|-----------|--------|
| **Máx/Mín D-1** | Nível de referência principal |
| **Bollinger Bands(20,2)** | Detectar squeeze + rompimento |
| **Volume** | Confirmar que o rompimento tem liquidez |
| **ATR(14)** | Projetar alvo após o rompimento |
| **MME200** | Filtro de tendência (só rompe a favor) |

---

## Estrutura dos Robôs BK

```
BK_01 — Breakout da máxima/mínima de D-1 + volume + MME200   (Profit .ntsl)
BK_02 — Bollin squeeze rompimento + alvo ATR × 2             (Profit .ntsl)
BK_03 — Range abertura (9:00–9:30) + rompimento candle 15min (Profit .ntsl)
BK_04 — MT5: Breakout diário XAUUSD / US30                   (MQL5 .mq5)
```

## Estrutura de Pastas
```
BREAKOUT/
├── breakout.md          ← este arquivo
├── codigo_fonte/        ← robôs Profit (.ntsl.txt)
└── mql5/                ← robôs MetaTrader (.mq5)
```
