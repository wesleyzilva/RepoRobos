# Grupo DUPLACONFIRMACAO (DC)

## Objetivo
Exigir **duas confirmações independentes** antes de entrar e **duas confirmações independentes** antes de sair. Nunca agir no primeiro sinal — esperar a segunda evidência.

---

## Filosofia

A dupla confirmação reduz entradas falsas ao custo de perder um pouco do início do movimento. A compensação é uma taxa de acerto significativamente maior.

| Aspecto | Simples | **Dupla Confirmação** |
|---------|---------|----------------------|
| Entradas erradas | Mais frequentes | Raras |
| Perde início do movimento | Não | Sim (aceito) |
| Taxa de acerto esperada | 55–65% | **> 68%** |
| Operações/dia | Mais | Menos (mais seletivo) |

---

## Regra de Entrada — 2 confirmações obrigatórias

Exemplos de pares válidos (qualquer combinação de 2 de camadas diferentes):

| Confirmação 1 (Gatilho) | Confirmação 2 (Contexto) |
|------------------------|--------------------------|
| IFR saindo de ZS/SO | Preço acima/abaixo de MME200 |
| Candle de força (corpo > 60%) | Volume acima da média |
| Estocástico crossover | ADX > 20 (tendência presente) |
| Bollinger toque externo | IFR em extremo (ZS/SO) |
| VWAP toque + rejeição | MME9 alinhada com MME200 |

> **Proibido:** entrar com apenas 1 sinal, mesmo que pareça óbvio.

---

## Regra de Saída — 2 confirmações obrigatórias

| Saída por alvo | Saída por reversão |
|---------------|-------------------|
| Alvo atingido **E** candle de fraqueza | IFR virou para zona oposta **E** volume caindo |
| Alvo atingido **E** IFR no extremo oposto | Candle de reversão **E** rompimento de MME9 |

> A saída por stop não precisa de confirmação — stop é stop.

---

## Indicadores Utilizados

| Indicador | Função |
|-----------|--------|
| **IFR(9)** | Gatilho primário de entrada/saída |
| **Estocástico(5,3)** | Confirmação secundária de entrada |
| **MME200** | Contexto — direção permitida |
| **MME9 / MME21** | Alinhamento de curto prazo |
| **Volume relativo** | Confirma interesse real no movimento |
| **ADX(14)** | Confirma que há tendência para seguir |
| **Bollinger(20,2σ)** | Extremo de preço + reversão |

---

## Estrutura dos Robôs DC

```
DC_01 — IFR extremo + Volume elevado (entrada) / IFR oposto + candle fraco (saída)
DC_02 — Bollinger externo + IFR ZS/SO / banda central atingida + Estocástico virando
DC_03 — MME9×MME21 cruzamento + ADX > 20 / cruzamento inverso + volume caindo
DC_04 — VWAP toque + IFR extremo / VWAP rompida + candle de reversão confirmado
```

---

## Critério de Aprovação no Backtest

| Métrica | Mínimo | Ideal |
|---------|--------|-------|
| Taxa de acerto | > 65% | > 72% |
| Profit Factor | > 1.6 | > 2.2 |
| R:R médio | ≥ 1:1.5 | ≥ 1:2 |
| Drawdown máximo | < 15% | < 8% |
| Operações totais | > 60 | > 100 |

> Este grupo aceita menos operações — a seletividade é proposital.
