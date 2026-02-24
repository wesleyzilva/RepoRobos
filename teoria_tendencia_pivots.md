# Teoria de Pivôs (Operacional Day Trade)

## 1. Conceito Objetivo
Um pivô de continuação nasce quando o mercado:

1. faz um **impulso** na direção principal,
2. entra em **retração** contra essa direção,
3. e depois **rompe o nível da retração** voltando ao sentido do impulso.

A confirmação final vem quando o(s) candle(s) seguinte(s) fecham a favor do movimento.

---

## 2. Estrutura Base do Pivô
Para aumentar assertividade, use esta sequência:

- **Tendência prévia:** 2 candles no mesmo sentido.
- **Retração:** 2 candles contra a tendência.
- **Rompimento:** candle atual supera o topo/fundo da retração.
- **Confirmação:** 1 ou 2 candles após o rompimento fechando a favor.

---

## 3. Quantidade de Candles por Timeframe
Referência prática para fortalecer pivô:

| Timeframe | Perna (impulso/retração) | Confirmação pós-rompimento |
| :--- | :--- | :--- |
| **2 min** | 3 a 5 candles | 1 candle |
| **5 min** | 4 a 7 candles | 1 a 2 candles |
| **15 min** | 5 a 10 candles | 2 candles |

Regra simples:
- Timeframe menor = mais ruído = confirmação mais rápida, porém menos robusta.
- Timeframe maior = menos ruído = confirmação mais lenta, porém mais confiável.

---

## 4. Leitura Direcional

### Pivô de Alta
- Tendência prévia de alta.
- Retração de baixa.
- Rompimento da máxima da retração.
- Fechamento(s) de confirmação acima do candle anterior.

### Pivô de Baixa
- Tendência prévia de baixa.
- Retração de alta.
- Rompimento da mínima da retração.
- Fechamento(s) de confirmação abaixo do candle anterior.

---

## 5. Hierarquia Visual (Setup Atual)
No operacional:

- **Verde/Vermelho:** candle de confirmação do pivô (rompimento).
- **Dourado:** confirmação de sequência após o pivô (1 ou 2 candles, conforme parâmetro).
- **Cinza:** sem confirmação estrutural.

---

## 6. Erros Comuns
- Operar pivô sem tendência prévia clara.
- Considerar qualquer pullback curto como retração válida.
- Entrar no primeiro rompimento sem confirmação.
- Ignorar contexto de horário e fluxo (abertura, PTAX, baixa liquidez).

---

## 7. Regra de Ouro
Sem estrutura + rompimento + confirmação, não é pivô operacional.

**Estrutura considerada no setup:**
- **Estrutura de Alta:** `Close > Highest(High[1], PeriodoEstrutura)`
- **Estrutura de Baixa:** `Close < Lowest(Low[1], PeriodoEstrutura)`

Sem uma dessas duas condições, o pivô não é validado e o candle permanece **cinza**.

No seu setup: **sem dourado, sem entrada** (quando estiver no modo mais seletivo).