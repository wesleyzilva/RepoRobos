# Grupo VWAP_INSTITUCIONAL (VI)

## Por que é Obrigatório Conhecer
A VWAP (Volume Weighted Average Price) é o indicador mais usado por traders institucionais. Fundos e mesas de operação **executam ordens usando a VWAP como referência**.

Entender a VWAP significa entender onde o "dinheiro grande" está operando — e com isso, saber quando vai com o fluxo ou quando está entrando cedo demais.

---

## Regras Fundamentais da VWAP

| Situação | Significado | Ação |
|----------|-------------|------|
| Preço acima da VWAP | Mercado em vantagem compradora | Favorecer compras |
| Preço abaixo da VWAP | Mercado em vantagem vendedora | Favorecer vendas |
| Preço tocando VWAP e rejeitando | Nível de suporte/resistência dinâmico | Entrada na direção da tendência |
| Cruzamento da VWAP com volume | Possível mudança de direção intraday | Sinalização |

---

## VWAP Simples vs. Ancoragem

| Tipo | Timeframe | Uso |
|------|-----------|-----|
| VWAP Diária | Intraday (reset todo dia) | Referência principal de trading |
| VWAP Semanal | Panorama de médio prazo | Filtro de trend |
| VWAP Ancorada | A partir de evento específico | Pós-notícia, pós-gap |

---

## Indicadores do Grupo

| Indicador | Função |
|-----------|--------|
| **VWAP Diária** | Nível central de operação |
| **VWAP + 1σ / +2σ** | Zonas de sobrecompra/sobrevenda |
| **Volume** | Confirma interesse institucional |
| **IFR(9)** | Gatilho na zona da VWAP |
| **MME200** | Contexto de tendência de fundo |

---

## Estrutura dos Robôs VI

```
VI_01 — Pullback na VWAP diária + IFR neutro + a favor da trend (Profit .ntsl)
VI_02 — Cruzamento da VWAP + volume acima média + MME200        (Profit .ntsl)
VI_03 — Distância 2σ VWAP + reversão + alvo na VWAP            (Profit .ntsl)
VI_04 — MT5: VWAP setup EURUSD / NAS100                        (MQL5 .mq5)
```

## Estrutura de Pastas
```
VWAP_INSTITUCIONAL/
├── vwap_institucional.md        ← este arquivo
├── ntsl/                        ← robôs Profit (.ntsl)
├── mql5/                        ← robôs MetaTrader (.mq5)
├── resultsBackTestTimeframe/    ← CSVs de resultado
└── reprovados/                  ← versões descartadas
```
