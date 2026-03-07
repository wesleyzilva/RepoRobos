# Grupo STOPTOLERANTE (ST)

## Objetivo
Robôs com **stop tolerante (largo, baseado em estrutura)** combinados com **estratégias de alta confluência**.

A filosofia é oposta ao PPV:
- **PPV:** stop curto, sai rápido, não devolve — aceita ganhos pequenos
- **STOPTOLERANTE:** stop largo, aguenta o ruído, busca movimentos maiores — aceita stops mais caros mas em menor frequência

---

## Filosofia do Grupo

| Característica | PPV | **STOPTOLERANTE** |
|----------------|-----|------------------|
| Stop | 60–100 pontos (fixo/ATR) | 150–400 pontos (estrutural) |
| Alvo | 80–150 pontos | 300–800 pontos (R:R ≥ 1:2) |
| R:R mínimo | 1:1 | **1:2 obrigatório** |
| Taxa de acerto esperada | > 65% | > 60% |
| Entradas/dia | 2–3 | 1 (alta seletividade) |
| Trailing stop | Agressivo | Suave — deixa o trade respirar |
| Break-even | Ativa cedo (60 pts) | Ativa tarde (150+ pts) |

> **Princípio:** uma entrada mais cara (stop maior) é aceitável se a estratégia tiver
> alta probabilidade de acerto e o alvo compensar em R:R ≥ 2:1.

---

## Por que Stop Estrutural é Melhor que Stop Fixo?

**Stop fixo (ex: 100 pts):** pode ser atingido pelo ruído normal do mercado antes do trade andar.

**Stop estrutural (abaixo de suporte/máxima do D-1/pivô):**
- Só invalida se o preço romper a estrutura de fato
- Filtro natural: se rompeu o pivô, o setup está errado mesmo
- Menos stops falsos = mais operações chegam ao alvo

```
EXEMPLO COMPRA:
  Entrada:   125.000
  Stop:      abaixo da mínima do candle D-1 = 124.200 → stop de 800 pts
  Alvo:      máxima do D-1 + extensão = 126.600 → alvo de 1.600 pts
  R:R = 1:2 ✓
```

---

## Indicadores Utilizados

| Indicador | Função no grupo ST |
|-----------|-------------------|
| **IFR(9)** | Gatilho de entrada (extremo + retorno) |
| **MME200** | Filtro de contexto (tendência maior) |
| **Pivô D-1** (High/Low do dia anterior) | Define o stop estrutural |
| **ATR(14)** | Dimensiona alvos (múltiplo do ATR) |
| **VWAP diário** | Zona de valor — confirma direção |
| **Volume relativo** | Filtra entradas de baixa liquidez |
| **MME9 + MME21** | Regime de mercado (tendência/lateral) |

---

## Estrutura dos Robôs ST

```
ST_01 — IFR extremo + MME200 + stop abaixo pivô D-1        (mais conservador)
ST_02 — Divergência IFR + confirmação candle + stop pivô   (alta taxa de acerto)
ST_03 — Gap força + corpo forte + stop abaixo candle D-1   (agressividade moderada)
ST_04 — Confluência máxima IFR+VWAP+MME+volume + stop ATR  (R:R 1:3)
```

---

## Critério de Aprovação no Backtest

| Métrica | Mínimo | Ideal |
|---------|--------|-------|
| Profit Factor | > 1.5 | > 2.0 |
| Taxa de acerto | > 58% | > 65% |
| R:R médio | ≥ 1:2 | ≥ 1:2.5 |
| Drawdown máximo | < 25% | < 15% |
| Operações totais | > 80 | > 150 |

> Com stop maior, é normal ter menos operações — o critério de operações mínimas
> é mais baixo que nos outros grupos.
