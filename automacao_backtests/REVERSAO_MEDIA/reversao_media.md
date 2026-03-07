# Grupo REVERSAO_MEDIA (RM)

## Por que é Obrigatório Conhecer
Mean Reversion (reversão à média) é a estratégia que explora o princípio de que preços se afastam da média e tendem a voltar. O WIN é conhecido por movimentos bruscos seguidos de retorno — o que torna este setup altamente eficiente.

Quando o preço está muito longe da VWAP ou das médias, **a probabilidade de retorno é estatisticamente alta** — especialmente em mercados sem tendência forte.

---

## Quando Funciona / Quando NÃO Funciona

| Cenário | Resultado |
|---------|-----------|
| Mercado lateral (ADX < 20) | ✅ Excelente — preço oscila entre extremos |
| Tendência fraca (ADX 20-25) | ⚠️ Funciona com filtros |
| Tendência forte (ADX > 30) | ❌ Evitar — o preço pode não voltar |
| Após gap de abertura | ⚠️ Gap pode ser preenchido (favorável) ou não (stop) |

> **Regra:** antes de operar reversão, verificar ADX. Se ADX > 30, não usar este grupo.

---

## Indicadores Utilizados

| Indicador | Função |
|-----------|--------|
| **Bollinger Bands(20,2)** | Extremos de desvio padrão |
| **IFR(9)** | Confirma extremo (ZS/SO) |
| **VWAP** | Alvo da reversão (retorno à média) |
| **ADX(14)** | Filtro — só opera se ADX < 25 |
| **Volume** | Confirma exaustão (volume cai no extremo) |

---

## Filosofia de Entrada e Saída

```
ENTRADA: Preço toca Bollinger externo + IFR extremo + volume caindo
ALVO:    Retorno à Bollinger central (média de 20) ou à VWAP
STOP:    Além da Bollinger externa (rompeu → a reversão falhou)
```

---

## Estrutura dos Robôs RM

```
RM_01 — Bollinger toque externo + IFR ZS/SO + alvo banda central (Profit .ntsl)
RM_02 — Distância 2σ da VWAP + IFR extremo + alvo VWAP           (Profit .ntsl)
RM_03 — ADX < 20 + IFR extremo + alvo MME20                      (Profit .ntsl)
RM_04 — MT5: Mean reversion EURUSD (mercado mais controlado)     (MQL5 .mq5)
```

## Estrutura de Pastas
```
REVERSAO_MEDIA/
├── reversao_media.md    ← este arquivo
├── codigo_fonte/        ← robôs Profit (.ntsl.txt)
└── mql5/                ← robôs MetaTrader (.mq5)
```
